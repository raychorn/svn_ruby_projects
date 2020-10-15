
=head1 NAME

FAC2 - Fixlet Automated Creation 2!

=head2 DESCRIPTION

 The long-awaited BigFix dream, revamped by matt_hauck@bigfix.com from code
 finally realized by jeremy_spiegel@bigfix.com. Made possible by reuseable code
 by chris_loer@bigfix.com, originally made possible by code from peter_loer@bigfix.com

 This module basically represents a Fixlet object. This has been expanded to
 also allow for Digests and Templates.

 Upon creation of a FAC2 object, if it already exists, as determined by
 (Sitename, Fixlet ID, IsFixlet), the rest of its properties will be queried
 from the database to populate this object with correct values.

 The properties of a FAC2 object are as follows, and can be accessed via the
 get<...>() commands.

  Sitename      => string;  the site name
  ID            => integer; the fixlet ID
  IsFixlet      => boolean; 1 --> Fixlet, 0 --> Digest / Template
  Version       => integer; the version number
  ApVersion     => integer; the approval version number
  Approval      => integer; the approval level
  ParentID      => integer; the ID of the digest this Fixlet/Digest lives in
  ContentType   => integer; 0 --> Fixlet/Digest, 1 --> Template, 2 --> "other file", else --> ???
  Fields        => array; array reference of references to 3-element arrays:
		[
			[fieldName, fieldNumber, fieldContents],
			...,	
		]

 Any changes made to a FAC2 object can be saved to the database (thus creating
 a new Fixlet version) via the function 'commit()'

 Approval levels can be set via the method 'setApproval()'

=head2 EXAMPLES

	use FAC2;

	my $fixlet;

	###
	# TO MODIFY AN EXISTING FIXLET...
	###

	# create a reference to an existing Fixlet	
	$fixlet = FAC2::new('EnterpriseSecurity', 600101, 1, TEST, $logfile);

	# change some fields
	$fixlet->modifyFields(\@modifiedFields);

	# move fixlet to the digest with id $newParentID
	$fixlet->setParentID($newParentID);

	# commit changes to database, and try to approve to previous
	# approval level (to a max of 3)
	$fixlet->commit($fixlet->getApproval());

	###
	# TO CREATE A NEW FIXLET...
	###

	# create a new FAC2 object
	$fixlet = FAC2::new('EnterpriseSecurity', 99999, 1, $parentID, \@fields, TEST, $logfile);

	# commit to database!
	$fixlet->commit();


=cut


###
# FAC2 object
package FAC2;

###
# STRICT Perl with WARNINGS!
use strict;
use warnings;

###
# DataBase Interface
use DBI;

###
# The max we will allow things to be approved in `commit()`
use constant MAX_APPROVAL => 3;

###
# Error "codes" that various function `die` with
our $E_NOCONNECT = "You are not connected to the database";
our $E_BADCONNECT = "Could not connect to the database";
our $E_BADPARAM = "Incorrect parameters";
our $E_QUERY = "Error executing query";

###
# Database login information
my $DSN;
my $USER;
my $PASS;


=head2 Methods

Following are methods that can be performed on FAC2 objects.

=cut


=item new()

 New Fixlets:
 new($siteName, $fixletID, $isFixlet, $parentID, \@fields, $test, $logfile)

 Existing Fixlets:
 new($siteName, $fixletID, $isFixlet, $test, $logfile)

 Creates a new FAC2 object with the given parameters

 DIES with $E_BADPARAM if bad parameters are given

=cut

sub new {

	my ($siteName, $fixletID, $isFixlet, $version, $parentID, $fields, $test, $logfile);
	if (scalar @_ == 7) {
		($siteName, $fixletID, $isFixlet, $parentID, $fields, $test, $logfile) = @_;
	} elsif (scalar @_ == 5) {
		($siteName, $fixletID, $isFixlet, $test, $logfile) = @_;
	} else {
		die $E_BADPARAM;
	}

	if (!defined $siteName || !defined $fixletID || !defined $isFixlet) {
		die "$E_BADPARAM: Must provide at least site name, fixlet ID and isFixlet to create a valid FAC2 object!";
	}

	if ($isFixlet != 0 && $isFixlet != 1) {
		die "$E_BADPARAM: IsFixlet must be either 0 or 1!";
	}

	my $this = {
		'SITENAME' 	=> $siteName,
		'ID'		=> $fixletID,
		'ISFIXLET'	=> $isFixlet,
		'LOGFILE'	=> $logfile,
		'TEST'		=> defined $test ? $test : 0,
		'CONNECTED' => 0
	};

	bless $this;

	if ($this->isNew()) {
		# new fixlets have version 0, approval version 0 and approval 0
		$this->{VERSION} = 0;
		$this->{APPROVALV} = 0;
		$this->{APPROVAL} = 0;
		# always create fixlets/digests, not templates
		$this->{CONTENTTYPE} = 0;

		# new fixlets require a parentID and set of fields
		if (!defined $parentID || !defined $fields) {
			die "$E_BADPARAM: Must provide a parent ID and array of fields for new Fixlets!";
		}
		$this->{PARENTID} = $parentID;
		$this->{FIELDS} = $fields;
	} else {
		$this->populate();
	}

	return $this;
}

# accessors
sub getSitename 	{ return (shift)->{SITENAME}; 	} 
sub getID 			{ return (shift)->{ID}; 		}
sub getIsFixlet 	{ return (shift)->{ISFIXLET}; 	}
sub getVersion 		{ return (shift)->{VERSION}; 	}
sub getApVersion	{ return (shift)->{APPROVALV}; 	}
sub getApproval		{ return (shift)->{APPROVAL}; 	}
sub getParentID 	{ return (shift)->{PARENTID}; 	}
sub getContentType 	{ return (shift)->{CONTENTTYPE};}
sub getFields 		{ return (shift)->{FIELDS}; 	}
sub getBLOB 		{ return (shift)->{BLOB}; 		}
sub getLogFile 		{ return (shift)->{LOGFILE}; 	}

sub isConnected		{ return (shift)->{CONNECTED};	}


=item setParentID($parentID)

	Set the value of the parentID so that next time this object is
	committed, it will live in this new digest ID

=cut

sub setParentID {
	my $this = shift;

	my ($parentID) = @_;
	$this->{PARENTID} = $parentID;
}


=item setFields(\@fields)

	Replace the current objects fields array with the given array pointer

=cut

sub setFields {
	my $this = shift;

	my ($fields) = @_;
	$this->{FIELDS} = $fields;
}


=item setBLOB($value)

	Replace the current objects fields array with the given array pointer

=cut

sub setBLOB {
	my $this = shift;

	my ($blob) = @_;

	$this->{CONTENTTYPE} = 2;
	$this->{BLOB} = $blob;
	$this->updateBLOBSize();
}


=item toString()

	Return a string representation of this FAC2 object for easy logging

=cut

sub toString {
	my $this = shift;

	my $type;
	if ($this->getIsFixlet()) {
		$type = "Fixlet";
	} else {
		if ($this->getContentType() == 0) {
			$type = "Digest";
		} elsif ($this->getContentType() == 1) {
			$type = "Template";
		} elsif ($this->getContentType() == 2) {
			$type = "File";
		} else {
			$type = "Unknown";
		}
	}

	return sprintf "<Type=%s ID=%d Site=%s>",
				$type, $this->getID(), $this->getSitename();
}


=item getConnection()

	If connected, return the DBI handler

	DIES with $E_NOCONNECT if not connected

=cut

sub getConnection {
	my $this = shift;

	if (!$this->isConnected()) {
		die $E_NOCONNECT;
	} else {
		return $this->{DBH};
	}
}


=item connect()

	Connects to the database and sets the {CONNECTED} flag to 1

	DIES with $E_BADCONNECT if cannot connect to DB

=cut

sub connect {
	my $this = shift;

	if (!$this->isConnected()) {
		$this->{DBH} = dbLogin($this->{TEST});
		$this->{CONNECTED} = 1;
	}
}


=item disconnect()

	Disconnects from the database and sets the {CONNECTED} flag to 0

=cut

sub disconnect {
	my $this = shift;

	if ($this->isConnected()) {
		$this->getConnection()->disconnect();
		$this->{CONNECTED} = 0;
	}
}


=item getName()

	Returns the official title/name of this Fixlet.
	(i.e. getField('Name', 0))

=cut

sub getName {
	my $this = shift;

	return $this->getField("Name", 0);
}


=item getField($targetName, $targetNum)

	Looks through fields and returns the value of the field
	with the given name and number.

	If the specified Field name/number cannot be found, `undef` is returned

=cut

sub getField {
	my $this = shift;

	my ($targetName, $targetNum) = @_;

	foreach my $fieldRef (@{ $this->getFields() }) {
		my ($fieldName, $fieldNum, $fieldContents) = @$fieldRef;
		if (lc $fieldName eq lc $targetName && $fieldNum eq $targetNum) {
			return $fieldContents;
		}
	}

	return undef;
}

=item getNthField($targetName, $targetNum)

	Looks through fields and returns the value of the N-th field
	with the given name.

	If the specified Field name/number cannot be found, `undef` is returned

=cut

sub getNthField {
	my $this = shift;

	my ($targetName, $targetNum) = @_;
	my $soFar = 0;

	foreach my $fieldRef (@{ $this->getFields() }) {
		my ($fieldName, $fieldNum, $fieldContents) = @$fieldRef;

		if (lc $fieldName eq lc $targetName) {
		    $soFar = $soFar + 1;
		    return $fieldContents if ($soFar == $targetNum);
		}
	}

	return undef;
}


=item isNew()

	Checks to see if this Fixlet exists yet by checking the
	PROPERTIES table

=cut

sub isNew {
	my $this = shift;

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();

	my $sql = qq{
		SELECT COUNT(*)
		FROM Properties
		WHERE Sitename = '$siteName'
			AND ID = $id
			AND isFixlet = $isFixlet
	};

	my $count = $this->dbSQuery($sql);

	if ($count >= 1) {
		return 0;
	} else {
		return 1;
	}

}


=item populate()

	This is for FAC2 objects for Fixlets that already exist. Populates
	the object with important information, like:
		- Version
		- Approval Version
		- Parent ID
		- Field Data

=cut

sub populate {
	my $this = shift;

	eval {
		$this->connect();
	};
	if ($@) {
		dbLog($@, $this->getLogFile());
		return 0;
	}

	$this->{VERSION} 	 = $this->retrieveVersion();
	$this->{APPROVALV} 	 = $this->retrieveApVersion();
	$this->{APPROVAL} 	 = $this->retrieveApproval();
	$this->{CONTENTTYPE} = $this->retrieveContentType();
	$this->{PARENTID} 	 = $this->retrieveParentID();
	$this->{FIELDS}		 = $this->retrieveTextFields();
	$this->{BLOB}		 = $this->retrieveBlob();

	$this->disconnect();
}


=item retrieveVersion()

 Retrieves latest version number based on:
 Sitename, fixletID, and isFixlet

=cut

sub retrieveVersion {
	my $this = shift;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	my $sql = qq{
		SELECT V.LatestVersion
		FROM Versions V
		WHERE 
				V.SiteName = '$siteName'
			AND V.IsFixlet = $isFixlet
			AND V.ID = $fixletID
		;
	};
	return $this->dbSQuery($sql);
}


=item retrieveApVersion($version = <current version>)

 Retrieves latest approval version number based on:
	Sitename, fixletID, isFixlet, and version

 DIES if no version is defined

=cut

sub retrieveApVersion  {
	my $this = shift;

	my ($version) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $version) {
		die "$E_BADPARAM: Fixlet object must have a version to find approval version!";
	}

	my $sql = qq{
		SELECT AP.LastApprovalVersion
		FROM Approval_Versions AP
		WHERE 
				AP.SiteName = '$siteName'
			AND AP.IsFixlet = $isFixlet
			AND AP.ID = $fixletID
			AND AP.Version = $version
		;
	};

	return $this->dbSQuery($sql);
}


=item retrieveApproval($version = <current version>, $apVersion = <current apversion>)

 Retrieves latest approval based on:
	Sitename, fixletID, isFixlet, version, and approval version

 DIES if no version is defined

=cut

sub retrieveApproval  {
	my $this = shift;

	my ($version, $apVersion) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $apVersion) {
		$apVersion = $this->getApVersion();
	}
	if (!defined $version || !defined $apVersion) {
		die "$E_BADPARAM: Fixlet object must have a version and approval version to find approval level!";
	}

	my $sql = qq{
		SELECT A.ApprovalLevel
		FROM Approval A
		WHERE 
				A.SiteName = '$siteName'
			AND A.IsFixlet = $isFixlet
			AND A.ID = $fixletID
			AND A.Version = $version
			AND A.ApprovalVersion = $apVersion
		;
	};

	return $this->dbSQuery($sql);
}


=item retrieveContentType($version = <current version>)

 Retrieves current content type based on:
	Sitename, fixletID, isFixlet, and version

 DIES if no version is defined

=cut

sub retrieveContentType {
	my $this = shift;

	my ($version) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $version) {
		die "$E_BADPARAM: Fixlet object must have a version to find ContentType!";
	}

	my $sql = qq{
		SELECT P.ContentType
		FROM Properties P
		WHERE 
				P.SiteName = '$siteName'
			AND P.IsFixlet = $isFixlet
			AND P.ID = $fixletID
			AND P.Version = $version
		;
	};

	return $this->dbSQuery($sql);
}


=item retrieveParentID($version = <current version>)

 Retrieves current parent ID based on:
	Sitename, fixletID, isFixlet, and version

 If no version is given, it will use the current version
 of the Fixlet, if it has already been set.

 DIES if no version is defined

=cut

sub retrieveParentID {
	my $this = shift;

	my ($version) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $version) {
		die "$E_BADPARAM: Fixlet object must have a version to find parent ID!";
	}

	my $sql = qq{
		SELECT P.ParentID
		FROM Properties P
		WHERE 
				P.SiteName = '$siteName'
			AND P.IsFixlet = $isFixlet
			AND P.ID = $fixletID
			AND P.Version = $version
		;
	};

	return $this->dbSQuery($sql);
}


=item retrieveTextFields($version = <current version>)

 Retrieves current text fields based on:
	Sitename, fixletID, isFixlet, and version

 If no version is given, it will use the current version
 of the Fixlet, if it has already been set.

 Textfields are returned as an array reference
 of references to 3-element arrays

 DIES if no version is defined

=cut

sub retrieveTextFields {
	my $this = shift;

	my ($version) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $version) {
		die "$E_BADPARAM: Fixlet object must have a version to find TextFields!";
	}

	my $sql = qq{
		SELECT TF.FieldName, TF.FieldNumber, TF.FieldContents
		FROM TextFields TF
		WHERE 
				TF.SiteName = '$siteName'
			AND TF.IsFixlet = $isFixlet
			AND TF.ID = $fixletID
			AND TF.Version = $version
		;
	};

	return $this->dbFetchAll($sql);
}

=item retrieveBlob($version = <current version>)

 Retrieves current blob fields based on:
	Sitename, fixletID, isFixlet, and version

 If no version is given, it will use the current version
 of the Fixlet, if it has already been set.

 DIES if no version is defined

=cut

sub retrieveBlob {
	my $this = shift;

	my ($version) = @_;

	my $siteName = $this->getSitename();
	my $isFixlet = $this->getIsFixlet();
	my $fixletID = $this->getID();

	if (!defined $version) {
		$version = $this->getVersion();
	}
	if (!defined $version) {
		die "$E_BADPARAM: Fixlet object must have a version to find Blob fields!";
	}

	my $sql = qq{
		SELECT BF.FieldContents
		FROM BlobFields BF
		WHERE 
				BF.SiteName = '$siteName'
			AND BF.IsFixlet = $isFixlet
			AND BF.ID = $fixletID
			AND BF.Version = $version

			AND BF.FieldName = '__BLOB'
			AND BF.FieldNumber = 0
		;
	};

	return $this->dbSQuery($sql);
}

# alias of commit() for backwards combatibility

sub addToDatabase {	return (shift)->commit(@_); }


=item commit($approvalLevel = 0)

	Connect to database and perform all the necessary steps
	to commit a new this version of this Fixlet with the
	given approval level (0 if unspecified)

	It will never be approved above MIN {<prev approval level>, MAX_APPROVAL}

	I considered separating the approving from the version-adding,
	but then I realized that this will add 4 more DB queries
	(checkin, approval_versions update, approval insert, check out)
	for each Fixlet we modify.  More efficient to leave it in.

	This also succesfully has obseleted modifyAndApprove():
	  $this->modifyFields(\@fields)
	  $this->commit($this->getApproval())

	Returns 1 on success, 0 on error

=cut

sub commit {
	my $this = shift;

	my ($approvalLevel) = @_;

	$approvalLevel = 0 unless defined $approvalLevel;

	# take minimum of my two maximums, and use that as the maxiumum
	my $max;
	if ($this->getApproval() >= MAX_APPROVAL) {
		$max = MAX_APPROVAL;
	} else {
		$max = $this->getApproval()
	}

	if ($approvalLevel > $max) {
		warn "Approval level $approvalLevel is greater than maximum allowed: $max.  Using $max...";
		$approvalLevel = $max;	
	}

	eval {
		$this->connect();
	};
	if ($@) {
		dbLog($@, $this->getLogFile());
		return 0;
	}

	my $name = $this->getField('Name', 0);
	my $template = $this->getField('Template', 0);

	# All content has a name
	if (!defined $name) {
		dbLog("Fixlets must have a Name field!");
		return 0;
	}

	# All Fixlets must have a template
	if ($this->getIsFixlet() && (!defined $template || $template !~ /^\d+$/)) {
		dbLog("Fixlets must have a Template field!");
		return 0;
	}

	# All BLOBs must have a correct __BLOBSize!
	$this->updateBLOBSize();

	# Update Field count!!
	$this->updateFieldCount();

	# SET THE NEW VERSION!
	if ($this->isNew()) {
		$this->{VERSION} = 0;
	} else {
		$this->{VERSION} += 1;
	}
	# New versions of Fixlets always start approval version at 0
	$this->{APPROVALV} = 0;

	# This ordering of inserts seems to be important because SQL Server
	# complains if it's in a different order
	# chris says approval_versions has to be before approval,
	# and versions has to be before properties and textfields
	eval {
		$this->getLock();
		$this->insertCheckout();
		$this->insertApproval_Versions();
		$this->insertApproval($approvalLevel);
		$this->insertVersions();
		$this->insertProperties();
		$this->insertTextfields();
		$this->insertBlobfields();
		$this->deleteCheckout();

		$this->getConnection()->commit();
	};
	if ($@) {
		if ($@ =~ /$E_NOCONNECT/) {
			dbLog("We somehow lost our DB connection!", $this->getLogFile());
		} else {
			dbLog("Unknown error occured: $@", $this->getLogFile());
		}

		dbLog("\n\nROLLING BACK...\n\n", $this->getLogFile());
		$this->getConnection()->rollback();
		$this->disconnect();
		return 0;
	} else {
		dbLog("Success comitting to database!", $this->getLogFile());
	}

	# approval level is updated!	
	$this->{APPROVAL} = $approvalLevel;

	$this->disconnect();
	return 1;
}


=item setApproval($approvalLevel)

	Sets the approval level for the current Fixlet.

=cut

sub setApproval {
	my $this = shift;

	my ($approvalLevel) = @_;

	eval {
		$this->connect();
	};
	if ($@) {
		dbLog($@, $this->getLogFile());
		return 0;
	}

	# SET THE NEW APPROVAL VERSION!
	$this->{APPROVALV} += 1;

	eval {
		$this->getLock();
		$this->insertCheckout();
		$this->insertApproval_Versions();
		$this->insertApproval($approvalLevel);
		$this->deleteCheckout();

		$this->getConnection()->commit();
	};
	if ($@) {
		if ($@ =~ /$E_NOCONNECT/) {
			dbLog("We somehow lost our DB connection!", $this->getLogFile());
		} else {
			dbLog("Unknown error occured: $@", $this->getLogFile());
		}

		dbLog("\n\nROLLING BACK...\n\n", $this->getLogFile());
		$this->getConnection()->rollback();
		$this->disconnect();
		return 0;
	} else {
		dbLog("Success approving to level $approvalLevel!", $this->getLogFile());
	}

	# Success! current approval is now $approvalLevel!
	$this->{APPROVAL} = $approvalLevel;

	$this->disconnect();
	return 1;

}


=item getLock()

	Step 0. Get TABLOCKX, HOLDLOCK on Versions table

=cut

sub getLock {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $sql = q{
		SELECT * FROM Versions
		WITH (TABLOCKX, HOLDLOCK)
		WHERE ID != ID
	};

	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();	
}


=item insertCheckout()

	Step 1. Check out the Fixlet

	DIES if cannot check out

=cut

sub insertCheckout {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();

	my $sql;

	$sql = qq{ 	
		SELECT COUNT(*)
		FROM Checkout
		WHERE
				Sitename = '$siteName'
			AND ID = $id
			AND IsFixlet = $isFixlet
	};
	my $sleepTime = 0;
	my $free = 0;
	do {
		my $checkedIn = $this->dbSQuery($sql);
		if ($checkedIn == 0) {
			$free = 1
		} else {
			dbLog("Fixlet checked out already, sleeping 20 seconds...", $this->getLogFile());
			sleep 20;
			$sleepTime += 20;
		}

	} until ($free || $sleepTime >= 60);

	die "Cannot modify Fixlet, it is still checked out!" unless $free;

	$sql = qq{
		INSERT INTO Checkout
			(Sitename, ID, IsFixlet, Version, Username, CreationTime)
		VALUES
			('$siteName', $id, $isFixlet, $version, '$USER', getutcdate())
	};

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}


=item insertApproval_Versions()

	Step 2. Insert data into the Approval_Versions table

	First approval version and Last Approval version are both
	always 0 for a new Fixlet version, whether a new Fixlet or not

=cut

sub insertApproval_Versions {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();
	my $apVersion 	= $this->getApVersion();

	my $sql;

	if ($apVersion == 0) {
		$sql = qq{
		INSERT INTO Approval_Versions
			(Sitename, ID, IsFixlet, Version, FirstApprovalVersion, LastApprovalVersion)
		VALUES
			('$siteName', $id, $isFixlet, $version, 0, $apVersion)
		};
	} else {
		$sql = qq{
		UPDATE Approval_Versions
		SET LastApprovalVersion = $apVersion
		WHERE SiteName = '$siteName'
			AND ID = $id
			AND IsFixlet = $isFixlet
			AND Version = $version
		};
	}

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}


=item insertApproval()

	Step 3. Insert data into the Approval_View0 view

=cut

sub insertApproval {
	my $this = shift;

	my ($approvalLevel) = @_;

	if (!defined $approvalLevel) {
		die "$E_BADPARAM: Must provide an approval level!";
	}

	$approvalLevel = int $approvalLevel;
	if ($approvalLevel < 0 || $approvalLevel > 5) {
		die "$E_BADPARAM: Approval Level must be between 0 and 5!";
	}

	my $dbh = $this->getConnection();

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();
	my $apVersion 	= $this->getApVersion();

	my $sql = qq{
		INSERT INTO Approval_View$approvalLevel 
			(Sitename, ID, IsFixlet, Version, ApprovalVersion, Username,
			 ApprovalTime, ApprovalLevel, AttributesMask, Notes)
		VALUES
			('$siteName', $id, $isFixlet, $version, $apVersion, '$USER',
			getutcdate(), $approvalLevel, 0, null)
	};

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}


=item insertVersions()

	Step 4. Insert data into the VERSIONS table

=cut

sub insertVersions {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $siteName = $this->getSitename();
	my $id = $this->getID();
	my $isFixlet = $this->getIsFixlet();
	my $version = $this->getVersion();

	my $sql;
	if ($version == 0) {
		$sql = qq{
			INSERT INTO Versions
				(Sitename, ID, IsFixlet, LatestVersion, FirstVersion)
			VALUES
				('$siteName', $id, $isFixlet, 0, 0)
		};
	} else {
		$sql = qq{
			UPDATE Versions
			SET LatestVersion = $version
			WHERE SiteName = '$siteName'
				AND ID = $id
				AND IsFixlet = $isFixlet
		};
	}

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);

	$sth->execute();
	$sth->finish();
}


=item insertProperties()

	Step 5. Insert data into the Properties table

=cut

sub insertProperties {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();
	my $parentID	= $this->getParentID();
	my $contenttype = $this->getContentType();

	my $escapedName = $dbh->quote($this->getName());

	my $sql = qq{
		INSERT INTO Properties
			(Sitename, ID, IsFixlet, Version, ParentID, CreationTime, Username,
			ContentType, Name)
		VALUES
			('$siteName', $id, $isFixlet, $version, $parentID, getutcdate(),
			'$USER', $contenttype, $escapedName)
	};

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}


=item insertTextfields()

	Step 6. Insert data into the Textfields table

=cut

sub insertTextfields {
	my $this = shift;

	my $dbh = $this->getConnection();

	$this->updateFieldCount();

	dbLog("inserting textfields...", $this->getLogFile());

	my $siteName 	= $this->getSitename();
	my $id 		= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();

	foreach my $field (@{ $this->getFields() }) {		
		my ($fieldName, $fieldNumber, $fieldContents) = @$field;

		$fieldName = $dbh->quote($fieldName);

		my $sql = qq{
			INSERT INTO TextFields
				(Sitename, ID, IsFixlet, Version, FieldName, FieldNumber, FieldContents)
			VALUES
				('$siteName', $id, $isFixlet, $version, $fieldName,	$fieldNumber, ?)
		};
		my $sth = $dbh->prepare($sql);
		dbLog("Inserting $fieldName, $fieldNumber = $fieldContents into database", $this->getLogFile());
		$sth->execute($fieldContents);
		$sth->finish();
	}
}

=item insertBlobfields()

	Step 7. Insert data into the Blobfields table

=cut

sub insertBlobfields {
	my $this = shift;

	my $blob = $this->getBLOB();

	return if (!defined $blob);

	my $dbh = $this->getConnection();

	$this->updateFieldCount();	

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();
	my $version 	= $this->getVersion();


	my $sql = qq{
		INSERT INTO BlobFields
			(Sitename, ID, IsFixlet, Version, FieldName, FieldNumber, FieldContents)
		VALUES
			('$siteName', $id, $isFixlet, $version, '__BLOB', 0, ?)
	};

	my $sth = $dbh->prepare($sql);
	dbLog($sql, $this->getLogFile());
	$sth->execute($blob);
	$sth->finish();
}


=item deleteCheckout()

	Step 8. Un check out the Fixlet

=cut

sub deleteCheckout {
	my $this = shift;

	my $dbh = $this->getConnection();

	my $siteName 	= $this->getSitename();
	my $id 			= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();

	my $sql = qq{
		DELETE FROM Checkout
		WHERE
			Sitename = '$siteName'
		AND	ID = $id
		AND IsFixlet = $isFixlet
	};

	dbLog($sql, $this->getLogFile());
	my $sth = $dbh->prepare($sql);
	$sth->execute();
	$sth->finish();
}


=item updateFieldCount()

	Counts the number of fields in this Fixlet and
	updates the [__FieldCount, 0] field.

=cut

sub updateFieldCount {
	my $this = shift;

	my $fields = $this->getFields();

	my $fieldCountRef;
	my $fieldCount = 0;

	foreach my $field (@$fields) {
		my $fieldName = $field->[0];
		my $fieldNumber = $field->[1];
		if ($fieldName eq '__FieldCount' && $fieldNumber == 0) {
			$fieldCountRef = $field;
		}
		$fieldCount++;
	}
	if (defined $fieldCountRef) {
		$fieldCountRef->[2] = $fieldCount;
	} else {
		push @$fields, ['__FieldCount', 0, $fieldCount + 1];
	}
}


=item updateBLOBSize()

	If this Fixlet has a BLOB field, this will update
	the [__BLOBSIze, 0] field to be correct

=cut

sub updateBLOBSize {
	my $this = shift;

	my $blob = $this->getBLOB();

	return unless (defined $blob);

	$this->setField('__BLOBSize', 0, length $blob);
}


=item modifyFields(\@modifiedFields)

	Overwrite the Fixlet object's fields with the field array given

=cut

sub modifyFields {
	my $this = shift;

	my ($modifiedFields) = @_;

	foreach my $modifiedFieldRef (@$modifiedFields) {
		my @modifiedField = @$modifiedFieldRef;
		my $fieldName = $modifiedField[0];
		my $fieldNumber = $modifiedField[1];
		my $fieldContents = $modifiedField[2];

		$this->setField( $fieldName, $fieldNumber, $fieldContents );		
	}
}


=item setField($targetName, $targetNumber, $newContents)

	Overwrite the specific field (name, number) with the value given.
	If the Fixlet currently doesn't have such a field, it will be added.

=cut

sub setField {
	my $this = shift;

	my ($targetName, $targetNumber, $newContents) = @_;

	my $fields = $this->getFields();

	foreach my $field (@$fields) {
		my $fieldName = $field->[0];
		my $fieldNumber = $field->[1];
		if (lc($fieldName) eq lc($targetName) && $fieldNumber == $targetNumber) {
			$field->[2] = $newContents;
			return;
		}
	}

	# If the field isn't already there, add it.
	push @$fields, [$targetName, $targetNumber, $newContents];

	$this->updateFieldCount();
}


=head2 Functions

Following are functions that can be run without creating a FAC2 object.

=cut


=item createDigest($siteName, $parentID, $name, $test, $logfile)

 Creates a digest

=cut

sub createDigest {
	my ($siteName, $parentID, $name, $test, $logfile) = @_;

	my @fields;

	push @fields, ['Name', 0, $name];
	push @fields, ['ChildDelay', 0, '0:0:1'];
	push @fields, ['Delay', 0, '0:0:1'];
	push @fields, ['__FieldCount', 0, (scalar @fields) + 1];

	my $newID = getNextDigestID($siteName, $test, $logfile);

	my $digest = FAC2::new($siteName, $newID, 0, $parentID, \@fields, $test, $logfile);

	$digest->commit();
	$digest->setApproval(MAX_APPROVAL);

	return $newID;
}


sub getIDByName {
    my ($siteName, $errata, $digestID, $test, $logfile) = @_;

    my $dbh = dbLogin($test);    

    my $sql = qq{
        SELECT a.id  
            FROM Properties a
            WHERE a.name like '$errata%'
                    AND a.Sitename = '$siteName'
                    AND a.IsFixlet = 1
		    AND a.parentID = $digestID
                    and a.version = (SELECT b.latestversion  
                            FROM versions b
                            WHERE b.id = a.id
                            AND b.Sitename = a.sitename
                            AND b.IsFixlet = a.isfixlet)
    };
    
        my $sth = $dbh->prepare( $sql );
        $sth->execute();
        
	my $results = $sth->fetchall_arrayref();
	if ($sth->err) {
		die "$E_QUERY: ".$sth->err."\n$sql\n";
	}
	$sth->finish();

        $dbh->disconnect();

	return $results;    
    
}

=item getNextID($id, $sitename, $test, $logfile)

	Queries the DB to find the first unused fixlet with an id sequentially
	increasing $id, starting with appending 01, then 02, etc...

=cut

sub getNextID {
	my ($id, $siteName, $test, $logfile) = @_;

	my $dbh = dbLogin($test);

	my $sql = qq{
		SELECT *  
		FROM Properties
		WHERE 	ID = ?
			AND Sitename = '$siteName'
			AND IsFixlet = 1
	};
	my $sth = $dbh->prepare( $sql );
	do {
		$id++;
		$sth->execute($id);
		dbLog("Trying id $id", $logfile);
	} until (!$sth->fetch());
	$sth->finish();
	$dbh->disconnect();
	dbLog("Settling on id $id", $logfile);
	return $id;
}


=item getNextDigestID($sitename, $test, $logfile)

	Queries the DB to find the next digest ID by finding the
	current maximum digest ID, and then increasing by one until
	a free ID is found.

=cut

sub getNextDigestID {
	my ($siteName, $test, $logfile) = @_;

	my $dbh = dbLogin($test);

	my $sql;
	my $sth;

	$sql = qq{
		SELECT MAX(ID)
		FROM Properties
		WHERE 	Sitename = '$siteName' 
				AND IsFixlet = 0
				AND ContentType = 0
	};
	$sth = $dbh->prepare( $sql );
	$sth->execute();

	my $max;	
	$sth->bind_columns( \$max );
	$sth->fetch();
	$sth->finish();

	# Is this looping necessary? Is it safe to just add one?
	# I think it's safe...but it kinda scares me to assume.
	my $id = $max;
	$sql = qq{
		SELECT ID
		FROM Properties
		WHERE ID = ? and Sitename = '$siteName' and IsFixlet = 0
	};
	$sth = $dbh->prepare( $sql );
	do {
		$id++;
		$sth->execute($id);
		dbLog("Trying id $id", $logfile);
	} until (!$sth->fetch());

	$sth->finish();
	$dbh->disconnect();
	dbLog("Settling on id $id", $logfile);
	return $id;
}


=item dbLogin($test)

 Do the actual logging in to the database.

 If $test is true, then log into bde_quixote, otherwise, log into bde_bdedb

 DIES with $E_BADCONNECT

=cut

sub dbLogin {
	my ($test) = @_;

	# TODO: Some day this LongReadLen value will fail.
	if($test == 1) {
		$DSN = "bde_quixote";
		$USER = "sa";
		$PASS = "q1w2e3!";
	} else {
		$DSN = "bde_bdedb";
		$USER = "content_author";
		$PASS = "bdeiscool";
	}
	my $dbh = DBI->connect("dbi:ODBC:$DSN", $USER, $PASS,
					{
						RaiseError => 1, 
						AutoCommit => 0, 
						LongReadLen => 1000000
					}
				) || die "$E_BADCONNECT: $DBI::errstr";

	return $dbh;
}


=item dbSQuery($sql)

 Do a database query and return one result from the first column
 This should be a _S_ingular result query

=cut

sub dbSQuery {
	my $this = shift;

	my ($sql) = @_;

	my $wasConnected = $this->isConnected();

	eval {
		$this->connect();
	};
	if ($@) {
		dbLog($@, $this->getLogFile());
		return 0;
	}
	my $dbh = $this->getConnection();

	my $sth = $dbh->prepare( $sql );
	$sth->execute();

	my $value;	
	$sth->bind_columns( \$value );
	$sth->fetch();
	if ($sth->err) {
		die "$E_QUERY: ".$sth->err."\n$sql\n";
	}
	$sth->finish();

	$this->disconnect() unless $wasConnected;

	return $value;
}


=item dbFetchAll($sql)

 Do a database query and return fetchall_arrayref

=cut

sub dbFetchAll {
	my $this = shift;

	my ($sql) = @_;

	my $wasConnected = $this->isConnected();

	eval {
		$this->connect();
	};
	if ($@) {
		dbLog($@, $this->getLogFile());
		return 0;
	}
	my $dbh = $this->getConnection();

	my $sth = $dbh->prepare( $sql );
	$sth->execute();

	my $results = $sth->fetchall_arrayref();
	if ($sth->err) {
		die "$E_QUERY: ".$sth->err."\n$sql\n";
	}
	$sth->finish();

	$this->disconnect() unless $wasConnected;

	return $results;
}


=item dbLog($say, $file, $quiet = 0)

 Logs the given text into the given file, prefixing with the current local time.

 If you specify $quiet to be 1, then the text is logged only and not displayed.
 Otherwise, it is both logged and displayed.

 If the directory does not exist for the logfile, it will be created.

 If an error occurs logging to the file, this will `warn` the user but will not die 

=cut

sub dbLog {
	my ($say, $file, $quiet) = @_;

	$quiet = 1 if !defined $quiet;

	my $msg = "[" . localtime() . "] " . $say . "\n";

	print $msg unless $quiet;

	return if (!defined $file);

	# if the file is in a directory, make sure it exists!
	if ($file =~ /[\\\/]/) {
		my $directory = $file;
		$directory =~ s/[\\\/][^\\\/]*?$//;
		if (! -e $directory) {
			if (!mkdir $directory) {
				warn "\nWARNING: Could not create directory '$directory' - $!\n";
				return;
			}
		}
	}

	if (!open (MLOG, '>>', $file)) {
		warn "\nWARNING: Unable to open $file for append - $!\n";	
	} else {
		print MLOG $msg;
		close MLOG || warn "\nWARNING: Unable to close $file - $!\n";
	}
}


1;
__END__
