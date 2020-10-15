my @foo;
push (@foo,['BAR',1,'TEST']);
push (@foo,['BAR',2,'TEST2']);
push (@foo,['BLAH',1,'BLAH1']);
            
my $test = encodeTextField (\@foo);
print $test;
my @plop = decodeTextField($test);

print "Done";

sub decodeTextField {
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
    return @fieldRef;
}

=item encodeTextField(\@fields)

    Takes the fields array and converts it to a binary string for BDE

=cut

sub encodeTextField {
  my ( $fieldArray ) = @_;
  
  my $serializedFields = pack 'V', scalar( @$fieldArray );
 
  for ( my $count = 0; $count < scalar @$fieldArray; $count++ )
  {
    my $ref = $fieldArray->[$count];
    my $serializedField = pack 'V C/a* V/a*', $ref->[1], $ref->[0], $ref->[2];
    $serializedFields .= $serializedField;
  }
  return $serializedFields;
}
