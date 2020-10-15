##############################################
# Gatherer.pm
#
# 	The Gatherer module was written to replace a previous "Gather.pl" 
# 	file that was used previously to "gather" a site and information
# 	about it. 
#
# 	The cons of that script were:
# 		* It was a perl script and not a perl module, making it more clunky to use
# 		* It downloaded the directory structure to disk, making it hard to clean up after
#
# 	This script aims to solve these problems with the following:
# 		* It is a module!
# 		* It does not download to disc.
# 		  Instead, it stores all the information in memory.  It GETs the gather URLs
# 		  and caches them in a global hash in case the same thing is gathered twice.
#
# 	Somemore benefits:
# 		* It only downloads what it needs. Instead of downloading the _whole_ site
# 		  including template information and graphics and other files and what not
# 		  is totally unecessary to get a Fixlet ID and relevance!  This will only
# 		  download FXF files until it finds the one it wants.
#
# 		* It provides a more sensical interface to the site data.  It will return 
# 		  the data in terms of fields instead of .fxf files.
#
# 	
#	Usage: Gatherer::getFields(...)
# 	
##############################################
package Gatherer;

use strict;
use warnings;

# don't import anything, so that we can "override" getURL
use MiscUtil qw();

# cache of gotten URLs: <url> => <contents>
our %CACHE;

###############################################
# getURL()
# 	interface to MiscUtil's 'getURL()' so as to 
# 	cache the websites 'gotten' already
#
sub getURL {  
	my ($url) = @_;

	if (!defined $CACHE{$url}) {
		$CACHE{$url} = MiscUtil::getURL($url);	
	}

	return $CACHE{$url};
}

###############################################
# getFields()
# 	Given a gather URL and a Fixlet ID, this will
# 	return an array of this Fixlet's fields in the
#	an array ref of array refs:
# 	[
#		[fieldName, fieldNum, fieldContents],
#		...,
# 	]
#
sub getFields {
	my ($gatherURL, $fixletID) = @_;

	# for each FXF, look for Fixlet ID
	my $fixlet;
	
	print "Gathering site at '$gatherURL'...\n";
	my $contents = getURL($gatherURL);
	
	my @fxfs;
	while ($contents =~ /URL: (.*?\.fxf)/ig) {
		push @fxfs, $1;
	}

	foreach my $fxf ( @fxfs ) { 
		#print "Searching FXF file '$fxf'...\n";
		$fixlet = findFixlet($fxf, $fixletID);
		last if defined $fixlet;		
	}

	die "Cannot find fixlet #$fixletID in site $gatherURL" 
		unless defined $fixlet;

	$fixlet =~ s/\r\n/\n/g;

	#print "Parsing FXF file for Fixlet fields for fixlet #$fixletID...\n";

	my @fields;

	# Name
	if ($fixlet =~ /Subject: (.*)/i) {
		my $field = $1;
		chomp $field;
		push @fields, ['Name', 0, $field];
	}

	# Relevance
	my $relNum = 1;
	while ($fixlet =~ /X-Relevant-When: (.*)/ig) {
		my $field = $1;
		chomp $field;
		push @fields, ['Relevance', $relNum, $field];
		$relNum++;
	}

	# Source ID, Source, Source Release Date, Download Size, Category, Default Action
	while ($fixlet =~ /X-Fixlet-(Source.*?|Download-Size|Category|Default-Action): (.*)/ig) {
		my $name = $1;
		my $contents = $2;
		chomp $contents;
		$name =~ s/-/ /g;
		push @fields, [$name, 1, $contents];
	}

	# SANS, CVE
	while ($fixlet =~ /X-Fixlet-(SANS|CVE): (.*)/ig) {
		my $name = $1;
		my $field = $2;
		chomp $field;
		push @fields, ['MIME_X-Fixlet-'.$name, 1, $field];
	}

	while ($fixlet =~ /(?<=--F$fixletID)(.*?)(?=--F$fixletID)/igs) {
		my $contents = $1;

		# Action
		while ($contents =~ /Content-id: Action(\d+)\nContent-Type: .*?\n\n(.*)/igs) {
			my $num = $1;
			my $field = $2;
			chomp $field;
			push @fields, ['Action', $num, $field];
		}

		# Field
		if ($contents =~ /Content-Type: text\/html/i) {
			if ($contents =~ /<!--#include file="\d+_1.txt"-->\n(?:<TABLE><TBODY><TR><TD>)?(.*?)(?:<\/TD><\/TR><\/TBODY><\/TABLE>)?\n<!--#include file="\d+_2.txt"-->/is) {
				my $field = $1;
				chomp $field;
				push @fields, ['__Field', 1, $field];
			}
		}
	}

	return \@fields;
}

###############################################
# findFixlet()
# 	Given a digest URL and a fixlet ID, this will
# 	return the section of the digest file that represents
# 	the given Fixlet
#
sub findFixlet {
	my ($digestURL, $fixletID) = @_;

	my $contents = getURL($digestURL);
	
	while ($contents =~ /(Subject: .*?--F\d+?--)/igs) {
		my $fixlet = $1;
		return $fixlet if $fixlet =~ /X-Fixlet-ID: $fixletID(?!\d)/i;
	}


	return undef;
}

1;
__END__
