package FAC3;

use strict;
use warnings;

use BigFixPM::util::db;
use BigFixPM::util::genericUtil;
use BigFixPM::util::Logger;

###
# Version Information
use constant FAC_VERSION => "3.14";
use constant MODIFIED_DATE => "10/8/2007";
use constant BDE_VERSION => "1.51";

###
# Error "codes" that various function `die` with
our $E_NOCONNECT = "You are not connected to the database";
our $E_BADCONNECT = "Could not connect to the database";
our $E_BADPARAM = "Incorrect parameters";
our $E_QUERY = "Error executing query";
our $E_BADVERSION = "FAC" . FAC_VERSION . " requires BDE version " . BDE_VERSION;

###
# DataBase Interface
use DBI;

sub new {
    my $args = parameterMap(@_);
    
    my ($siteName,
        $fixletID,
        $isFixlet,
        $version,
        $parentID,
        $fields,
        $test,
        $logfile,
        $user,
        $password,
        $dsn);    
  
    if (defined $args->{BASIC} && scalar @{$args->{BASIC}}>0){
        if (scalar @{$args->{BASIC}} == 7) {
                ($siteName, $fixletID, $isFixlet, $parentID, $fields, $test, $logfile) = @{$args->{BASIC}};
        } elsif (scalar @{$args->{BASIC}} == 5) {
                ($siteName, $fixletID, $isFixlet, $test, $logfile) = @{$args->{BASIC}};
        } else {
                die $E_BADPARAM;
        }
        ### I hope to convert all scripts to requiring the user/pass/dsn combination.
        ### Until then this is neccesary.
        if($test == 1) {
                $dsn = "bde_quixote";
                $user = "sa";
                $password = "q1w2e3!";
        } else {
                $dsn = "bde_bdedb";
                $user = "content_author";
                $password = "bdeiscool";
        }
    } else {
         $siteName = $args->{SITE};
         $fixletID = $args->{ID};
         $isFixlet = defined $args->{ISFIXLET}?$args->{ISFIXLET}:1;
         $parentID = $args->{PARENTID};
         $fields   = $args->{FIELDS};
         $logfile  = $args->{LOGFILE};
         $user     = $args->{USER};
         $password = $args->{PASSWORD};
         $dsn      = $args->{DSN};
    }

    if (!defined $siteName || !defined $fixletID) {
            die "$E_BADPARAM: Must provide at least site name and fixlet ID to create a valid FAC".FAC_VERSION . " object!";
    }

    if ($isFixlet != 0 && $isFixlet != 1) {
            die "$E_BADPARAM: IsFixlet must be either 0 or 1!";
    }

    if (!defined $user || !defined $password || !defined $dsn){
        die "$E_BADPARAM: -user, -password, and -dsn are required.";
    }

    my $this = {
            'SITENAME' 	=> $siteName,
            'ID'	=> $fixletID,
            'ISFIXLET'	=> $isFixlet,
            'LOGFILE'	=> $logfile ,
            'TEMPLATES' => {},
    };

    bless $this;
    
    push (@{$this->{CALLER}},caller);
    
    $this->{DB} = BigFixPM::util::db::new(-user => $user,
                                          -password => $password,
                                          -dsn => $dsn);
    if (defined $logfile){
        $this->{LOG} = BigFixPM::util::Logger::new(-file => $logfile,
                                                -prompt => "FAC".FAC_VERSION.":",
                                                -verbose => defined $args->{VERBOSE}?$args->{VERBOSE}:0);
    } else {
        $this->{LOG}->write = sub {};
    }
    
    if (!$this->checkBDEVersion()){
        die "$E_BADVERSION";
    }
    
    if ($this->isNew()){
        $this->dbLog("$fixletID is a new fixlet.");
        $this->{VERSION} = 0;
        $this->{APPROVALV} = 0;
        $this->{APPROVAL} = 0;
        # always create fixlets/digests, not templates
        $this->{CONTENTTYPE} = 0;

        # new fixlets require a parentID and set of fields
        if (!defined $parentID || !defined $fields) {
                $this->dbLog("$E_BADPARAM: Must provide a parent ID and array of fields for new Fixlets!");
                die "$E_BADPARAM: Must provide a parent ID and array of fields for new Fixlets!";
        }
        $this->{PARENTID} = $parentID;
        $this->{FIELDS} = $fields;
    } else {
        $this->dbLog("$fixletID exists.");
        $this->populate();
    }
    
    return $this;
}

### Basic Data Accessors
sub getName             { return (shift)->getField('Name',0);}
sub getID 		{ return (shift)->{ID}; 	     }
sub getSitename         { return (shift)->{SITENAME};        }
sub getIsFixlet 	{ return (shift)->{ISFIXLET}; 	     }
sub getVersion 		{ return (shift)->{VERSION}; 	     }
sub getApVersion	{ return (shift)->{APPROVALV}; 	     }
sub getApproval		{ return (shift)->{APPROVAL}; 	     }
sub getParentID 	{ return (shift)->{PARENTID}; 	     }
sub getContentType 	{ return (shift)->{CONTENTTYPE};     }
sub getFields 		{ return (shift)->{FIELDS}; 	     }
sub getBLOB 		{ return (shift)->{BLOB}; 	     }
sub getLogFile 		{ return (shift)->{LOG}->logFile;    }
sub isConnected		{ return (shift)->{DB}->isConnected; }
sub getDB               { return (shift)->{DB};              }
sub dbLog               { (shift)->{LOG}->write(@_);         }

sub isNew {
	my $this = shift;

	my $siteName 	= $this->getSitename();
	my $id 		= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();

	my $sql = qq{
		SELECT COUNT(*)
		FROM Properties
		WHERE Sitename = '$siteName'
			AND ID = $id
			AND isFixlet = $isFixlet
	};

	my $count = $this->{DB}->dbSQuery($sql);

	if ($count >= 1) {
		return 0;
	} else {
		return 1;
	}

}

sub commit { (shift)->execInsertObject(); }

sub getNextID {
        my $args = parameterMap(@_);
        
	my $id = $args->{ID};
        my $siteName = $args->{SITENAME};
        my $logfile = $args->{LOGFILE};
        my $user = $args->{USER};
        my $password = $args->{PASSWORD};
        my $dsn = $args->{DSN};

        my $db = BigFixPM::util::db::new(-user => $user,
                                          -password => $password,
                                          -dsn => $dsn);

        my $log = BigFixPM::util::Logger::new(defined $logfile?(-file => $logfile):'',
                                                -prompt => "FAC".FAC_VERSION.":");

	my $sql = qq{
		SELECT *  
		FROM Properties
		WHERE 	ID = ?
			AND Sitename = '$siteName'
			AND IsFixlet = 1
	};
	#my $sth = $dbh->prepare( $sql );
	#do {
	#	$id++;
	#	$sth->execute($id);
	#	dbLog("Trying id $id", $logfile);
	#} until (!$sth->fetch());
	#$sth->finish();
	#$dbh->disconnect();
	#dbLog("Settling on id $id", $logfile);
	#return $id;
}

sub setApproval { (shift)->execApproveObject($_[0]); }

sub checkBDEVersion {
    my $this = shift;

    my $sql = qq{
            SELECT Version
            FROM DBINFO
    };

    my $version = $this->{DB}->dbSQuery($sql);

    if ($version != BDE_VERSION) {
            return 0;
    } else {
            return 1;
    }    
}

sub execApproveObject {
    my $this = shift;
    my $apLevel = shift;
    
    my $user        = $this->{DB}->getUser();
    my $siteName    = $this->getSitename();
    my $id          = $this->getID();
    my $isFixlet    = $this->getIsFixlet();
    my $version     = $this->getVersion();
    
    my $sql = qq{exec approve_object ?,?,?,?,?,?,?};
    
    $this->dbLog("Approving $id to $apLevel.");
    $this->{DB}->storedProcedure($sql,$user,$siteName,$id,$isFixlet,$version,$apLevel,0);
    $this->{APPROVAL} = $apLevel;
}

sub execInsertObject {
    my $this = shift;
    
    my $sitename    = $this->getSitename();
    my $isFixlet    = $this->getIsFixlet();
    my $id          = $this->getID();
    my $name        = $this->getName();
    my $parentID    = $this->getParentID();
    my $contentType = $this->getContentType();
    my $fields      = $this->encodeFields($this->getFields());
    my $user        = $this->{DB}->getUser();
    
    my $sql = qq{exec insert_object ?,?,?,?,?,?,?,?};
    $this->dbLog("Commiting $id to the database.");
    $this->{DB}->storedProcedure($sql,$sitename,$id,$isFixlet,$parentID,$user,$contentType,$name,$fields);
    
    $this->populate();
}


sub setField {
	my $this = shift;

	my ($targetName, $targetNumber, $newContents) = @_;

	my $fields = \@{$this->getFields()};

	foreach my $field (@$fields) {
		my $fieldName = $field->[0];
		my $fieldNumber = $field->[1];
		if (lc($fieldName) eq lc($targetName) && $fieldNumber == $targetNumber) {
                        $this->dbLog("$fieldName [$fieldNumber] updated from '$field->[2]' to '$newContents'.");
			$field->[2] = $newContents;
			return;
		}
	}
	# If the field isn't already there, add it.
        $this->dbLog("$targetName [$targetNumber] added with the value '$newContents'.");
	push @$fields, [$targetName, $targetNumber, $newContents];

}

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

sub encodeFields {
  my $this = shift;
  
  my ( $fieldArray ) = @_;
  
  my $serializedFields = pack 'V', scalar( @$fieldArray );
 
  for ( my $count = 0; $count < scalar @$fieldArray; $count++ )
  {
    my $ref = $fieldArray->[$count];
    my $serializedField = pack 'V C/a* V/a*', $ref->[1], $ref->[0], $ref->[2];
    $serializedFields .= $serializedField;
  }
  $this->dbLog("Encoded " . scalar( @$fieldArray ) . " fields." );
  return $serializedFields;
}

sub decodeFields {
    my $this = shift;
    
    my $serializedFields = shift;
    
    my @fieldRef;
    
    my $fieldCount = unpack 'V', $serializedFields;
    $serializedFields = substr $serializedFields, 4;
    
    for ( my $count = 0; $count < $fieldCount; $count++ ) {
        my @fields = unpack 'V C/a V/a', $serializedFields;
     
        # 4 bytes (field count) + 1 byte (name length) + name length bytes + 4 bytes (contents length) + contents length bytes
    
        $serializedFields = substr( $serializedFields, 9 + length( $fields[1] ) + length( $fields[2] ) );
        push (@fieldRef,[$fields[1],$fields[0],$fields[2]]);
    }
    $this->dbLog("Decoded " . scalar( @fieldRef ) . " fields." );
    return @fieldRef;
}


sub getTemplate {
    my $this = shift;
    my $templateName = shift;
    
    
}

## getTemplateID
##
## If you supply a template name as a parameter it will
## return that ID
##
## If you don't supply a parameter it will return the
## current fixlets template ID.
sub getTemplateID {
    my $this = shift;
    my $templateName = shift;
    
    if (defined $templateName){
        if (defined $this->{TEMPLATES}->{$templateName}){
            return $this->{TEMPLATES}->{$templateName}->{ID};
        } else {
            return -1;
        }
    } else {
        foreach my $field (@{$this->{FIELDS}}){
            if ($field->[0] eq "Template"){
                return $field->[2];
            }
        }
    }
    return -1;
}

sub retreiveTemplates {
    my $this = shift;
    
    my $siteName = $this->getSitename();
    
    my $sql = qq{SELECT ID, Name, ApprovalLevel, Fields
                 FROM
                    current_object_defs
                WHERE ContentType = 1
                AND Sitename = ?
                AND parentID <> 1};
    
    my $templates = $this->{DB}->dbFetchAll($sql,$siteName);
    
    foreach my $template (@$templates){
        $this->dbLog("Loading template " . $template->[1]);
        with (%{$this->{TEMPLATES}->{$template->[1]}},
                'ID' => $template->[0],
                'NAME' => $template->[1],
                'APLEVEL' => $template->[2],
            );
        push(@{$this->{TEMPLATES}->{$template->[1]}->{FIELDS}}, $this->decodeFields($template->[3]));
    }
    $this->dbLog("Loaded " . scalar @{$templates} . " templates from the database");
}

sub populate {
	my $this = shift;

	my $siteName 	= $this->getSitename();
	my $id 		= $this->getID();
	my $isFixlet 	= $this->getIsFixlet();

        my $sql = qq{
          SELECT
            version,
            parentid,
            contenttype,
            approvallevel,
            fields
          FROM CURRENT_OBJECT_DEFS
          WHERE Sitename = '$siteName'
            AND ID = $id
            AND IsFixlet = $isFixlet
        };
        $this->dbLog("Loading properties.");
        my $properties = $this->{DB}->dbFetchAll($sql);
        
	$this->{VERSION} 	 = $properties->[0]->[0];
        $this->{PARENTID} 	 = $properties->[0]->[1];
        $this->{CONTENTTYPE}     = $properties->[0]->[2];
	$this->{APPROVAL} 	 = $properties->[0]->[3];
        
        if (!defined $this->{FIELDS}){ # If you supply a fields array it will be used.
            $this->dbLog("Loading new fields");
            push(@{$this->{FIELDS}},$this->decodeFields($properties->[0]->[4]));
        }
        
        $this->retreiveTemplates();
        
	#$this->{BLOB}		 = $this->retrieveBlob();
}

1;

__END__