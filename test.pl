# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test;
BEGIN { plan tests => 1 };
use strict;
use Text::Diff;
use Text::Patch;

my $t1 = '
The Way that can be told of is not the eternal Way;
The name that can be named is not the eternal name.
The Nameless is the origin of Heaven and Earth;
The Named is the mother of all things.
Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
';

my $t2 = '
The Nameless is the origin of Heaven and Earth;
The named is the mother of all things.

Therefore let there always be non-being,
  so we may see their subtlety,
And let there always be being,
  so we may see their outcome.
The two are the same,
But after they are produced,
  they have different names.
They both may be called deep and profound.
Deeper and more profound,
The door of all subtleties!
';

my $patch = diff( \$t1, \$t2, { STYLE => "Unified" } );

print "[$patch]\n";

my $t3 = patch( $t1, $patch, { STYLE => "Unified" } );

print "original: [$t2]\npatched: [$t3]";

print $t2 eq $t3 ? "\n\n*** YES ***\n\n" : "\n\n*** NO ***\n\n";

ok(1) if $t2 eq $t3;

