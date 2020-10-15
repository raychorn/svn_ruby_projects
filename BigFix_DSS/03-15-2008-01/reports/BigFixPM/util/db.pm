package BigFixPM::util::db;

use strict;
use warnings;

use BigFixPM::util::genericUtil;

use DBI;

###
# Error "codes" that various function `die` with
our $E_NOCONNECT = "You are not connected to the database";
our $E_BADCONNECT = "Could not connect to the database";
our $E_QUERY = "Error executing query";
our $E_BADPARAM = "Incorrect parameters";

sub new {
    my $args = parameterMap(@_);
    
    my $this = {
        'USER' => $args->{USER},
        'PASSWORD' => $args->{PASSWORD},
        'DSN' => $args->{DSN},
        'CONNECTED' => 0,
    };
    
    
    if (!defined $this->{USER} || !defined $this->{PASSWORD} || !defined $this->{DSN}){
        die "$E_BADPARAM:  BigFixPM::util::db requires -user, -password, and -dsn";       
    }
    
    bless $this;
    
    return $this;

}

sub isConnected { return (shift)->{CONNECTED}; }
sub getUser { return (shift)->{USER}; }

=item dbLogin($test)

 Do the actual logging in to the database.

 If $test is true, then log into bde_quixote, otherwise, log into bde_bdedb

 DIES with $E_BADCONNECT

=cut

sub dbLogin {
    my $this = shift;

    my $dbh = DBI->connect("dbi:ODBC:".$this->{DSN}, $this->{USER}, $this->{PASSWORD},
                                    {
                                            RaiseError => 1, 
                                            AutoCommit => 0, 
                                            LongReadLen => 1000000
                                    }
                            ) || die "$E_BADCONNECT: $DBI::errstr";

    return $dbh;
}


sub storedProcedure {
    my $this = shift;
    my $sql = shift;

    my $wasConnected = $this->isConnected();

    eval {
            $this->connect();
    };
    if ($@) {
            #dbLog($@, $this->getLogFile());
            print $@."\n";
            return 0;
    }
    my $dbh = $this->getConnection();    
    
    my $sth = $dbh->prepare( $sql );
    $sth->execute(@_);
    $sth->finish();
    $dbh->commit();
    
    if ($sth->err) {
    	die "$E_QUERY: ".$sth->err."\n$sql\n";
    }
    
    $this->disconnect() unless $wasConnected;
}

=item connect()

	Connects to the database and sets the {CONNECTED} flag to 1

	DIES with $E_BADCONNECT if cannot connect to DB

=cut

sub connect {
	my $this = shift;

	if (!$this->isConnected()) {
		$this->{DBH} = $this->dbLogin();
		$this->{CONNECTED} = 1;
	}
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

=item dbSQuery($sql)

 Do a database query and return one result from the first column
 This should be a _S_ingular result query

=cut

sub dbSQuery {
	my $this = shift;

	my ($sql) = shift;

	my $wasConnected = $this->isConnected();

	eval {
		$this->connect();
	};
	if ($@) {
		#dbLog($@, $this->getLogFile());
                print $@."\n";
		return 0;
	}
	my $dbh = $this->getConnection();

	my $sth = $dbh->prepare( $sql );
	$sth->execute(@_);

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

	my ($sql) = shift;

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
	$sth->execute(@_);

	my $results = $sth->fetchall_arrayref();
	if ($sth->err) {
		die "$E_QUERY: ".$sth->err."\n$sql\n";
	}
	$sth->finish();

	$this->disconnect() unless $wasConnected;

	return $results;
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


1;
