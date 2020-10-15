package BigFixPM::util::genericUtil;

use strict;
use warnings;

################################
#Function List:
#
# parameterMap (@_):
#
#   Takes in a set of parameters from a sub.
#   It returns an associative array based on
#   -<KEY> => <VALUE>
#   If any parameters are not noted with '-' they
#   are placed in $obj->{BASIC}
#
# with (\%hash,
#   'KEY'  => 'VALUE',
#   'KEY2' => 'VALUE2',);
#
#   This function takes everything after the first
#   parameter and applies it to the hash reference
#   supplied.  This helps clean up code when you have
#   a big hierarchy of references.
#   No return, applies by reference. Also does not
#   overwrite existing keys and values.
#
# getFilename ($string)
#
#   This function gets the filename from the end of a
#   string or URL
#
#   

require Exporter;
	
our @ISA = qw(Exporter);
our @EXPORT = qw(
    parameterMap
    with
    getFilename
);

sub getFilename {
	my $file = shift;
	if ($file =~ /[\\|\/](.[^\\|\/]+?)$/){
	    return $1;
	} else {
	    return $file
	}
	return $file;

}

sub with (\%@) {
    my $obj=shift;
    
    while ( my ($key, $value) = splice (@_, 0, 2) ) {
        $obj->{$key}=$value;
    }
}

sub parameterMap {
    my $obj = {};
    my @args = @_;
    
    for (my $p_count = 0; $p_count <= $#args; $p_count++){
        if ($args[$p_count] =~ /^-(.*)$/){
            $obj->{uc $1}=$args[$p_count+1];
            $p_count++;
        } else {
            push(@{$obj->{BASIC}},$args[$p_count]);
        }
    }
    
    return $obj;
}


1;

    
