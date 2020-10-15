package BDEDigest;

use FAC2;

use strict;
use warnings;

###############################################
# searchForDigest()
# 	Checks to see if $siteName
# 	contains a digest directly under $parentID 
# 	that contains the $searchText in its name
#
# 	If the digest exists, returns its ID
# 	If the digest doesn't exist, returns -1
# 	
sub searchForDigest {
	my ($siteName, $parentID, $searchText, $testFlag) = @_;

	my $sql = qq{
		SELECT P.ID
		FROM Properties P
		
		INNER JOIN Versions V ON
				P.ID = V.ID
			AND P.IsFixlet = V.IsFixlet
			AND P.SiteName = V.SiteName
			AND P.Version = V.LatestVersion
				
		WHERE 	P.ParentID = $parentID 
			AND P.ContentType = 0
			AND P.IsFixlet = 0
			AND P.SiteName = '$siteName'
			AND P.Name LIKE '$searchText'
	};

	my $digestID = dbSQuery($sql, $testFlag);
	if (!defined $digestID) {
		$digestID = -1;
	}

	return $digestID;
} # searchForDigest()

sub getNewDigestId {
	my ($siteName, $dateString) = @_;
	
	
} # getNewDigestId()

# given the id of a parent,
# returns a stack of digest names; highest parent at the top
# special case for '1Windows Updates' and similiar crap

sub getDigestStack {
	my ($siteName, $parentId, $test, $logfile) = @_;
	my @outputStack;
	
	while ($parentId != 0) {
		my $digest = FAC2::new($siteName, $parentId, 0, $test, $logfile);
		my $name = $digest->getName();
		if ($name =~ /^1[^\d]/) {
			$name = substr($name, 1);
		}
		push(@outputStack, $name);
		$parentId = $digest->getParentID();
		
	}
	return @outputStack;
	
} # getDigestStack()

sub printDigestStack {

	my @digestStack = @_;
	print join("\n", reverse(@digestStack)) . "\n";
	
}

##############################################
# dbSQuery()
# 	Do a database query and return one result from the first column
# 	This should be a _S_ingular result query
# 	
sub dbSQuery {
	my ($sql, $testFlag) = @_;

	my $DBH = FAC2::dbLogin($testFlag);
	
	my $sth = $DBH->prepare( $sql );
	$sth->execute();

	my $value;	
	$sth->bind_columns( \$value );
	$sth->fetch();
	if ($sth->err) {
		die "Error executing query '$sql': ".$sth->err;
	}
	$sth->finish();

	$DBH->disconnect();
	return $value;
}

#given a digest id in source site, will create identical
#digest tree in dest site and return the new parent digest id
sub mirrorDigests { 
	my ($sourceSite, $destSite, $parentId, $testFlag, $logfile) = @_;
	
	my @digestStack = getDigestStack($sourceSite, $parentId, $testFlag, $logfile);
	
	my $oldParentId = 0;
	while (scalar @digestStack > 0) {
		my $digestName = pop(@digestStack);
		my $newParentId = searchForDigest($destSite, $oldParentId, $digestName, $testFlag);
		
		if ($newParentId == -1) {
			print "Creating new digest " . $digestName . " in " . $destSite . "\n";
			$newParentId = FAC2::createDigest($destSite, $oldParentId, $digestName, $testFlag, $logfile);
		}
		
		$oldParentId = $newParentId;
		
	}
	
	return $oldParentId;
	
} #mirrorDigests()

1;

__END__;