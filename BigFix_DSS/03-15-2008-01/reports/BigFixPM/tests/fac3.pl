use strict;
use warnings;

use BigFixPM::bde::FAC3;

### New FAC3
 my $fac = FAC3::new(-id => 705102,
                     -site => 'EnterpriseSecurity',
                     -user => "content_author",
                     -password => 'bdeiscool',
                     -dsn => 'bde_fubar',
                     -logfile => 'c:\fac3.log',
                     -verbose => 1,
                    );
 
 
print $fac->getTemplateID();

my $oldName = $fac->getName();

#$fac->setApproval(4);

$fac->setField('Name',0,'Foobar2');

$fac->commit();

print "Name Changed\n";

$fac->setField('Name',0,$oldName);

$fac->commit();

print "Changed Back";