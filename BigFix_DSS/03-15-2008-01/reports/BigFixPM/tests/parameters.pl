#my $fac = FAC3::new(
my @fields = (["name",1,"foo"],["bob",1,"bar"]);

my $args = parameterMap (-id => 123456,
                -contentType => 1, 
                -site => 'Enterprise Security',
                -user => 'user',
                -password => 'password',
                -dsn => 'odbc_dsn',
                -fields => \@fields,
                -logfile => 'non-default.log',
                );

print "pause";

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