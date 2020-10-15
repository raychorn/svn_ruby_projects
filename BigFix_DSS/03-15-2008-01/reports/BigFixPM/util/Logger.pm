package BigFixPM::util::Logger;

use BigFixPM::util::genericUtil;

use strict;
use warnings;

sub new {
    my $args = parameterMap(@_);
    my $this = {
        'FILE' => $args->{FILE},
        'PROMPT' => defined $args->{PROMPT}?$args->{PROMPT}:'',
        'VERBOSE' => defined $args->{VERBOSE}?$args->{VERBOSE}:0,
    };
    
    bless $this;
    
    push (@{$this->{CALLER}},caller);
    if (!defined $this->{FILE}){
        $this->{FILE} = getFilename($this->{CALLER}->[1]);
        $this->{FILE} .= ".log";
    }
    
    return $this;
}

#accessor, set/get
sub logFile {
    my $this = shift;
    my $file = shift;
    
    if (defined $file){
        $this->{FILE} = $file;
    }
    
    return $this->{FILE};
}

sub write {
    my $this = shift;
    my $string = shift;
    
    open (FILE, ">>".$this->{FILE}) or die "Couldn't open ". $this->{FILE} ." for writing." . $this->{CALLER} . "\n";
    
    if ($this->{VERBOSE}) {
        print $this->{PROMPT} . " " . $string . "\n";
    }
    print FILE $this->{PROMPT} . " " . $string . "\n";
    
    close (FILE);
}



1;
