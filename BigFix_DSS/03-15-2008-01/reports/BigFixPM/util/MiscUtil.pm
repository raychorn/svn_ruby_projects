=head1 NAME

Contains many useful utilities

=cut

package MiscUtil;

use strict;
use warnings;

use MIME::Lite;

use LWP::UserAgent;
use HTTP::Cookies;

use Digest::SHA1;
use Digest::MD5;
use Time::HiRes;

our $E_NOFILE 		= "File does not exist";
our $E_OPENFILE 	= "Cannot open file";
our $E_CLOSEFILE 	= "Cannot close file";
our $E_DOWNLOAD 	= "Could not download file";
our $E_NOHTTP		= "HTTP Request failed";
our $E_EMAIL 		= "Could not send email";
our $E_DBCONNECT	= "Database connection not made";

our $UA;

our %CURRENT_DL;
our $HEADERS;

# The maximum amount of time (cumulative) to sleep in waiting for 
# for a broken link to become unbroken
use constant MAX_SLEEP => 120;

use constant CHUNK_SIZE => 8 * 1024;

require Exporter;
	
our @ISA = qw(Exporter);
our @EXPORT = qw(
		getSHA1 getMD5 getSize formatFileSize
		downloadFile getURLHeaders getURL postURL
		mainLog getSomeLog
		sendMail
		existsInList posInList urlEncode
		readFile writeToFile appendToFile
		prompt confirm proceed
		$E_NOFILE $E_OPENFILE $E_CLOSEFILE $E_DOWNLOAD $E_NOHTTP $E_EMAIL $E_DBCONNECT 
);


=item setUA($newUA)

 Sets the global $UA variable for MiscUtil
 
=cut

sub setUA {
	my ($newUA) = @_;
	
	if ((ref $newUA) =~ /LWP::UserAgent/i) {
		$UA = $newUA;
		return 1;
	} else {
		return 0;
	}
}

=item getSHA1($file)

 Calculate the SHA1 checksum of the given file path

 DIES with $E_OPENFILE or $E_CLOSEFILE upon error
 
=cut

sub getSHA1 {
	my ($file) = @_;
	
	return undef unless -e $file;

	my $sha1 = Digest::SHA1->new;

	open FILE, "<", $file || die "$E_OPENFILE: '$file' - $!";
	binmode FILE;
	$sha1->addfile(*FILE);
	close FILE || die "$E_CLOSEFILE: '$file' - $!";
	
	return $sha1->hexdigest;
}


=item getMD5($file)

 Calculate the MD5 checksum of the given file path

 DIES with $E_OPENFILE or $E_CLOSEFILE upon error
 
=cut

sub getMD5 {
	my ($file) = @_;
	
	return undef unless -e $file;

	my $md5 = Digest::MD5->new;

	open FILE, "<", $file || die "$E_OPENFILE: '$file' - $!";
	binmode FILE;
	$md5->addfile(*FILE);
	close FILE || die "$E_CLOSEFILE: '$file' - $!";
	
	return $md5->hexdigest;
}

=item getSize($file)

 Calculate the size (in bytes) of the given file path

 DIES with $E_NOFILE if file does not exist
 
=cut

sub getSize {
	my ($file) = @_;
	
	die "$E_NOFILE: '$file'" unless -e $file;
	
	my $size = (stat($file))[7];
	
	return $size;	
}


=item downloadFile($dlLink, $file, $quiet = 1)

 Downloads the file given to it to the destination given. If you would not like
 the status to be reported, set $quiet to 0.

 DIES with $E_DOWNLOAD if an error occurs during download
 
=cut

sub downloadFile {
	my ($url, $file, $quiet) = @_;
	
	my $urlFilename = $url;
	$urlFilename =~ s/.*\///;
	
	if (!defined $file || $file eq "") {
		$file = $urlFilename;
	}
	
	$quiet = 0					unless (defined $quiet);
	$UA = new LWP::UserAgent() 	unless (defined $UA);
		
	%CURRENT_DL = (
		'FILENAME' => $urlFilename,
		'RECEIVED_SIZE' => 0,
		'TO_REPORT' => 0,
		'LAST_UPDATE' => Time::HiRes::time,
		'FILE' => $file,
		'QUIET' => $quiet,
		'IS_TTY' => -t STDOUT
	);
	
	eval {
		unlink $file if -e $file;
		my $old = $|;
		$| = 1;
		my $response = $UA->get($url, ':content_cb' => \&partialDL, ':read_size_hint' => CHUNK_SIZE);
		$| = $old;
	};
	if ($@) {
		print "\n\n" unless $quiet;
		die "$E_DOWNLOAD: '$url'; $@";
		unlink $file if -e $file;
	}
	
	print "\nDownload complete!\n\n" unless $quiet;
	print "\n\n" unless ($quiet || defined $CURRENT_DL{CHECKED_SIZE});
	


	return $file;
}


=item partialDL($data, $response, $protocol)

 Callback function for downloadFile() that keeps track of download statistics
 to print out.  Also writes progressive data to file
 
 DIES with $E_NOHTTP if the HTTP response is not a success
 DIES with $E_OPENFILE or $E_CLOSEFILE if an error occurs writing data out to file
 
=cut

sub partialDL {
	my ($data, $response, $protocol) = @_;

	die "$E_NOHTTP: HTTP Response: (".$response->code.") ".$response->message unless $response->is_success;

	if (!defined $CURRENT_DL{CHECKED_SIZE}) {
		print "\nDownloading '".$CURRENT_DL{FILENAME}."' " unless $CURRENT_DL{QUIET};
		
		my $size = $response->header('Content-Length');
		if (defined $size) {
			$CURRENT_DL{TOTAL_SIZE} = $size;
			printf "[%s]\n", formatFileSize($size) unless $CURRENT_DL{QUIET};
		} else {
			print "[unknown size]\n" unless $CURRENT_DL{QUIET};
		}
		$CURRENT_DL{CHECKED_SIZE} = 1;
	}

	return if (length $data == 0);

	my $received = length $data;
	$CURRENT_DL{TO_REPORT} += $received;
	$CURRENT_DL{RECEIVED_SIZE} += $received;
			
	open FILE, '>>', $CURRENT_DL{FILE} || die "$E_OPENFILE: '$CURRENT_DL{FILE}' - $!";
	binmode FILE;
	print FILE $data;
	close FILE || die "$E_CLOSEFILE: '$CURRENT_DL{FILE}' - $!";
	
	$CURRENT_DL{THIS_UPDATE} = Time::HiRes::time;
	my $timeDiff = $CURRENT_DL{THIS_UPDATE} - $CURRENT_DL{LAST_UPDATE};
		
	if (defined $CURRENT_DL{TOTAL_SIZE} && $CURRENT_DL{TOTAL_SIZE} == $CURRENT_DL{RECEIVED_SIZE}) {
		reportPartialDL($timeDiff) unless $CURRENT_DL{QUIET};
		return;
	}
	
	# this to make the status only update once per second.
	return if ($timeDiff < 1 && $CURRENT_DL{IS_TTY});
	return if ($timeDiff < 2 && !$CURRENT_DL{IS_TTY});
	
	reportPartialDL() unless $CURRENT_DL{QUIET};
	
	$CURRENT_DL{LAST_UPDATE} = $CURRENT_DL{THIS_UPDATE};
	$CURRENT_DL{TO_REPORT} = 0;
}


=item reportPartialDL()

 Print out an update statement on the current download status based on
 the CURRENT_DL hash which is maintained by partialDL()

=cut

sub reportPartialDL {
	
	my $timeDiff = $CURRENT_DL{THIS_UPDATE} - $CURRENT_DL{LAST_UPDATE};
	
	my $string = "";
	$string .= sprintf "Received %s", formatFileSize($CURRENT_DL{RECEIVED_SIZE});
	$string .= sprintf "  (%i%%)", 100 * ($CURRENT_DL{RECEIVED_SIZE} / $CURRENT_DL{TOTAL_SIZE})
		if (defined $CURRENT_DL{TOTAL_SIZE});
	$string .= sprintf "  %.1f KB/s", ($CURRENT_DL{TO_REPORT} / 1024) / ($timeDiff || 1);
	
	# can only do backspacing on TTY's
	if ($CURRENT_DL{IS_TTY}) {
		if (defined $CURRENT_DL{MAX_REPORT}) {
			# backspace over maximum report
			for (my $i = 0; $i < $CURRENT_DL{MAX_REPORT}; $i++) {
				print "\b";
			}
			
			# compensate for differing string lengths
			my $thisLength = length $string;
			for (my $i = 0; $i < $CURRENT_DL{MAX_REPORT} - $thisLength; $i++) {
				$string .= " ";
			}
		}
		
	} else {
		print "\n";
	}

	print $string;

	if (!defined $CURRENT_DL{MAX_REPORT} || length $string > $CURRENT_DL{MAX_REPORT}) {
		$CURRENT_DL{MAX_REPORT} = length $string;
	}
}


=item getURLHeaders($url, $header = "")
	
 Performs a HEAD request on the given URL.  If you specify a header
 that you are looking for (i.e. 'Content-Length'), then this will
 only return the value of that header.  If you do not specify a header
 this will return an HTTP::Headers object containing all headers

 DIES with $E_NOHTTP if HTTP response is eventually a failure
 
=cut

sub getURLHeaders {
	my ($url, $header) = @_;
	
	$UA = new LWP::UserAgent() 	unless (defined $UA);
	
	# clear data just in case...
	$HEADERS = undef;
	
	my $headers;
	# it will indeed die so that the whole thing doesn't download
	eval {
		my $response = $UA->get($url, ':content_cb' => \&getHeaders, ':read_size_hint' => 1);
	};
	if (defined $HEADERS) {
		my $headers = $HEADERS;
		
		# clear data for future use
		$HEADERS = undef;
		
		if (defined $header) {
			return $headers->header($header);
		} else {
			# an HTTP::Headers object
			return $headers;
		}
		
	} else {
		return undef;
	}
	
	
	#my $response = $UA->head($url);
	#if (!$response->is_success) {
	#	my $sleep = 10;
	#	if ($sleepTime < MAX_SLEEP) {
	#		sleep $sleep;
	#		return getURLHeaders($url, $header, $sleepTime + $sleep);
	#	} else {
	#		die "$E_NOHTTP: '$url'; HTTP Response: ($response->code) $response->message";
	#	}
	#} else {
	#	if (defined $header) {
	#		return $response->header($header);
	#	} else {
	#		# an HTTP::Headers object
	#		return $response->headers;
	#	}
	#}
}


=item getHeaders()

 Callback function for getURLHeaders() that gets headers
 from the response object.
 
 It appears that the headers from a GET request are not
 all returned in a HEAD request!
 
=cut

sub getHeaders {
	my ($data, $response, $protocol) = @_;
	
	die "$E_NOHTTP: HTTP Response: (".$response->code.") ".$response->message unless $response->is_success;
	
	$HEADERS = $response->headers;
	
	die;
}

=item getURL($url)
	
 Performs a GET request on the given URL.  

 DIES with $E_NOHTTP if HTTP response is eventually a failure
 
=cut

sub getURL {
	my ($url, $sleepTime) = @_;
	
	$sleepTime = 0 				unless (defined $sleepTime);
	$UA = new LWP::UserAgent() 	unless (defined $UA);
	
	my $response = $UA->get($url);
	if (!$response->is_success) {
		my $sleep = 10;
		if ($sleepTime < MAX_SLEEP) {
			sleep $sleep;
			return getURL($url, $sleepTime + $sleep);
		} else {
			die "$E_NOHTTP: '$url'; HTTP Response: (".$response->code.") ".$response->messageI;
		}
	} else {
		return $response->content;
	}
}

=item postURL($url, \%data)
	
 Performs a POST request on the given URL, with the given data

 DIES with $E_NOHTTP if HTTP response is eventually a failure
 
=cut

sub postURL {
	my ($url, $data, $sleepTime) = @_;
	
	$sleepTime = 0 				unless (defined $sleepTime);
	$UA = new LWP::UserAgent() 	unless (defined $UA);
	
	if (!defined $UA->cookie_jar) {
		my $cookie_jar = HTTP::Cookies->new();
		$UA->cookie_jar($cookie_jar);
	}
	
	my $response = $UA->post($url, $data);
	if (!$response->is_success) {
		my $sleep = 10;
		if ($sleepTime < MAX_SLEEP) {
			sleep $sleep;
			return postURL($url, $data, $sleepTime + $sleep);
		} else {
			die "$E_NOHTTP: '$url'; HTTP Response: (".$response->code.") ".$response->message;
		}
	} else {
		return $response->content;
	}
}

=item formatFileSize($totalSize)

 Given a file size (in bytes) this will return a string using the most-applicable
 units (Bytes, KB, MB) with at least 3 significant digits, and no more than 2 decimal places
	
=cut

sub formatFileSize {
	my ($totalSize) = @_;
	
	my $suffix;
	my $newSize;
	if ($totalSize < 1024) {
		$newSize = $totalSize;
		$suffix = "Bytes";
	} elsif ($totalSize < (1024 * 1024)) {
		$newSize = $totalSize / 1024;
		$suffix = "KB";
	} else {
		$newSize = $totalSize / (1024 * 1024);
		$suffix = "MB";
	}
	
	my $formattedSize;
	if (int($newSize) < 10) {
		$formattedSize = sprintf "%.2f %s", $newSize, $suffix;
	} elsif (int($newSize) < 100) {
		$formattedSize = sprintf "%.1f %s", $newSize, $suffix;
	} else {
		$formattedSize = sprintf "%d %s", int($newSize), $suffix;
	}   

	return $formattedSize;
}


=item mainLog($say, $file, $quiet = 0)

 Logs the given text into the given file, prefixing with the current local time.
 
 If you specify $quiet to be 1, then the text is logged only and not displayed.
 Otherwise, it is both logged and displayed.

 If the directory does not exist for the logfile, it will be created.

 If an error occurs logging to the file, this will `warn` the user but will not die 

=cut

sub mainLog {
	my ($say, $file, $quiet) = @_;

	$quiet = 0 unless defined $quiet;
	
	my $msg = "[" . localtime() . "] " . $say . "\n";
	
	print $msg unless $quiet;

	return unless defined $file;
	
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


=item getSomeLog($max, $logfile)
	
	Returns at most $max lines from the _end_ of $logfile.
	
	If an error occurs, it will simply return an empty string.
	
=cut

sub getSomeLog {
	my ($max, $logfile) = @_;
	
	return "" if ($max <= 0);
	
	my @lines;
	my @fileLines;
	eval {
		@fileLines = split /\n/, readFile($logfile);
	};
	if ($@ =~ /$E_OPENFILE/) {
		return "";
	}
		
	if (scalar @fileLines <= $max) {
		@lines = @fileLines;
	} else {
		while (scalar @lines < $max) {
			unshift @lines, (pop @fileLines);
		}
	}
	
	return join "\n", @lines;
}


=item sendMail($subject, $from, $to, $message, $attachment, $attachment2)

 Sends an email using MIME::Lite with the given specs
 
 DIES with $E_EMAIL if an error occurs creating/sending the email

=cut

sub sendMail {
	my ($subject, $from_address, $emailsTo, $message, $attachment, $attachment2) = @_;
	
	my ($sec, $min, $hour, $day, $month, $year) = localtime(time);
    my $date = sprintf "%02d\/%02d\/%4d", $month + 1, $day, $year + 1900;
	my $smtp;
	
	my $to_address = join ', ', @$emailsTo;

	my $mime_type = 'TEXT';
	
	# Create the initial text of the message
	my $mime_msg = MIME::Lite->new(
	   From => $from_address, 
	   To   => $to_address, 
	   Subject => $subject . " ($date)", 
	   Type => 'multipart/mixed'
	) || die $E_EMAIL;
	  
	# Attach the body
	$mime_msg->attach (
	  Type => 'TEXT', 
	  Data => $message
	) || die $E_EMAIL;

	# Attach file 1
	if (defined $attachment){
		$mime_msg->attach (
		   Type => 'text/plain',
		   Path => "$attachment",
		   Filename => "$attachment",
		   Disposition => 'attachment'
		) || die $E_EMAIL;
	}
	
	# Attach file 2
	if (defined $attachment2){
		$mime_msg->attach (
		   Type => 'text/plain',
		   Path => "$attachment2",
		   Filename => "$attachment2",
		   Disposition => 'attachment'
		) || die $E_EMAIL;
	}

	my $mail_host = "bmail.bigfix.com";
	
	### Send the Message
	MIME::Lite->send('smtp', $mail_host, Timeout => 60);
	$mime_msg->send || die $E_EMAIL;
}


=item existsInList(@$haystack, $needle)

 Looks to see if the needle is in the haystack
 Returns 1 if it does, 0 if it doesn't
	
=cut

sub existsInList {
	my ($haystack, $needle) = @_;
	foreach my $item (@$haystack) {
		if ($item eq $needle) {
			return 1;
		}
	}
	return 0;
}


=item posInList(@$haystack, $needle)

 Looks to see if the needle is in the haystack
 Returns its position if it does, -1 if it doesn't
	
=cut

sub posInList {
	my ($haystack, $needle) = @_;
	for (my $i = 0; $i < scalar @$haystack; $i++) {
		if (@$haystack[$i] eq $needle) {
			return $i;
		}
	}
	return -1;
}


=item urlEncode($text)

 Makes the given text URL encoded

=cut

sub urlEncode {
    my ($text) = @_;
	
    $text =~ s/([^a-z0-9_.!~*'(  ) -])/sprintf "%%%02X", ord($1)/gei;
    $text =~ tr/ /+/;
	
    return $text;
}


=item readFile($file)

 Reads the given file and returns its contents as string
 
 DIES with $E_OPENFILE or $E_CLOSEFILE if an error occurs

=cut

sub readFile {
	my ($file) = @_;
	
	my $contents;
	open FILE, $file || die "$E_OPENFILE: '$file' - $!";
	foreach my $line (<FILE>) {
	    $contents .= $line;
	}
	close FILE || die "$E_CLOSEFILE: '$file' - $!";
	
	return $contents;
}


=item writeToFile($data, $file, $binary = 0)

 Overwrites the given file with the given data. 
 If $binary is set to 1, then the data will be written in binmode
 
 DIES with $E_OPENFILE or $E_CLOSEFILE if an error occurs

=cut

sub writeToFile {
	my ($data, $file, $binary) = @_;
	
	$binary = 0 unless defined $binary;

	open FILE, '>', $file || die "$E_OPENFILE: '$file' - $!";
	binmode FILE if $binary;
	print FILE $data;
	close FILE || die "$E_CLOSEFILE: '$file' - $!";
}


=item appendToFile($add, $file)

 Appends the given text plus a new line "\n" character to the given file
 
 DIES with $E_OPENFILE or $E_CLOSEFILE if an error occurs

=cut

sub appendToFile {
	my ($add, $file) = @_;
	
	open FILE, '>>', $file || die "$E_OPENFILE: '$file' - $!";
	print FILE $add . "\n";
	close FILE || die "$E_CLOSEFILE: '$file' - $!";
}


=item prompt($promptString)

 Ask the user a question, and return his response

=cut

sub prompt {
	my ($promptString) = @_;
	
	print $promptString;
	my $answer = <STDIN>;
	if (!defined $answer) {
		exit;
	}
	chomp $answer;
	return $answer;
}

=item confirm($confirmString)

 Ask the user a yes/no question until he responds
 with something starting with y or n.

 If the user responds positively, return 1
 Otherwise, return 0

=cut

sub confirm {
	my ($confirmString) = @_;
	
	print "\n-------\n";
	my $continue = "";
   	while ($continue !~ /^(y|n)/i) {
		$continue = prompt($confirmString." (yes/no) ");
	}
	print "\n";
	
	if ($continue !~ /^y/i) {
		return 0;
	}
	return 1;
}

=item proceed($confirmString)

 Ask the user a yes/no question until he responds
 with something starting with y or n.

 If the user responds negatively, the program will exit. 
 Otherwise, it will keep going

=cut

sub proceed {
	my ($confirmString) = @_;
	
	unless (confirm($confirmString)) {
		print "\nExiting...\n";
		exit;
	}
}

1;
__END__
