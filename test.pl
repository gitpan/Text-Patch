# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

use Test::More;
use strict;
use Text::Patch;
use constant DATA_SEP => ( "----8<----" x 7 )."\n";

#use Log::Trace;
#import Log::Trace 'warn' => { Deep => 1 };

my @styles = qw/Unified Context OldStyle/;

my $t1 = 'The Way that can be told of is not the eternal Way;
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

my $t2 = 'The Nameless is the origin of Heaven and Earth;
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

chomp(my $t1b = $t1);
chomp(my $t2b = $t2);

my @data; # [ text1, text2, style, break, testname]

# test different styles with different data
for my $style (@styles) {
    push @data, [$t1,  $t2,  $style, 0, "normal"];
    push @data, [$t1,  $t2b, $style, 0, "t2 no newline"];
    push @data, [$t1b, $t2,  $style, 0, "t1 no newline"];
    push @data, [$t1b, $t2b, $style, 0, "t1,t2 no newline"];
}

# test breaking it with bad hunks
for my $style (@styles) {
    push @data, [$t1, $t2, $style, 1, "bad hunk"];
}

# test a tricky patch
for my $style (@styles) {
    push @data, ["foo\nbar", "foo\n", $style, 0, "tricky patch"];
}

# use the --update option to update test data
update_patches(@data) if grep '--update', @ARGV;

# read patch data
my @patches = split DATA_SEP, join "", <DATA>;
close DATA or die $!;
die "Patch data not up to date with tests, use --update to update\n"
    unless @patches == @data;

plan tests => scalar @data;

for my $d (@data) {
    my($test1, $test2, $style, $break, $name) = @$d;
    my $patch = shift @patches;
    $test1 =~ s/(\r\n|\n)/ -- broken --$1/ if $break;

    my $test3 = eval { patch( $test1, $patch, { STYLE => $style } ) };
    my $error = $@;
    my $testname = "patch $style ($name)";
    my $ok;
    if($break) {
        $ok = ok($error, $testname);
    } else {
        $ok = is($test2, $test3, $testname);
    }
    unless($ok) {
        diag "error: $error" if $error;
        DUMP("$style patch", $patch);
        DUMP("original", $test2);
        DUMP("patched", $test3);
    }
}

# end tests
######################################################################

# update patches.  requires gnu diff
sub update_patches {
    my(@tests) = @_;
    my $version = `diff -v`;
    die "Could not determine diff version\n" unless $version;
    chomp $version;
    die "Requires gnu diff, not '$version'" unless $version =~ /GNU/;

    require File::Slurp;
    import File::Slurp qw/read_file write_file/;
    my @patches;
    my %diff_opt = ('Unified' => '-u',
                    'Context' => '-c',
                    'OldStyle' => '',
                   );
    for my $t (@tests) {
        my($test1, $test2, $style, $break, $name) = @$t;

        write_file("A", $test1) || die $!;
        write_file("B", $test2) || die $!;
        my $opt = $diff_opt{$style};
        my $patch = `diff --label A --label B $opt A B`;

        push @patches, $patch;
    }
    my $self = read_file($0) || die $!;
    $self =~ s/^(__DATA__\n).*//ms;

    $self .= "__DATA__\n" . join DATA_SEP, @patches;
    write_file($0, $self) || die $!;
    unlink($_) for qw/A B/;
    print "updated $0 patch data\n";
    exit 0;
}


#$t1 = 'here';
#$t2 = 'there';

__DATA__
--- A
+++ B
@@ -1,7 +1,6 @@
-The Way that can be told of is not the eternal Way;
-The name that can be named is not the eternal name.
 The Nameless is the origin of Heaven and Earth;
-The Named is the mother of all things.
+The named is the mother of all things.
+
 Therefore let there always be non-being,
   so we may see their subtlety,
 And let there always be being,
@@ -9,3 +8,6 @@
 The two are the same,
 But after they are produced,
   they have different names.
+They both may be called deep and profound.
+Deeper and more profound,
+The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
--- A
+++ B
@@ -1,7 +1,6 @@
-The Way that can be told of is not the eternal Way;
-The name that can be named is not the eternal name.
 The Nameless is the origin of Heaven and Earth;
-The Named is the mother of all things.
+The named is the mother of all things.
+
 Therefore let there always be non-being,
   so we may see their subtlety,
 And let there always be being,
@@ -9,3 +8,6 @@
 The two are the same,
 But after they are produced,
   they have different names.
+They both may be called deep and profound.
+Deeper and more profound,
+The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
--- A
+++ B
@@ -1,11 +1,13 @@
-The Way that can be told of is not the eternal Way;
-The name that can be named is not the eternal name.
 The Nameless is the origin of Heaven and Earth;
-The Named is the mother of all things.
+The named is the mother of all things.
+
 Therefore let there always be non-being,
   so we may see their subtlety,
 And let there always be being,
   so we may see their outcome.
 The two are the same,
 But after they are produced,
-  they have different names.
\ No newline at end of file
+  they have different names.
+They both may be called deep and profound.
+Deeper and more profound,
+The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
--- A
+++ B
@@ -1,11 +1,13 @@
-The Way that can be told of is not the eternal Way;
-The name that can be named is not the eternal name.
 The Nameless is the origin of Heaven and Earth;
-The Named is the mother of all things.
+The named is the mother of all things.
+
 Therefore let there always be non-being,
   so we may see their subtlety,
 And let there always be being,
   so we may see their outcome.
 The two are the same,
 But after they are produced,
-  they have different names.
\ No newline at end of file
+  they have different names.
+They both may be called deep and profound.
+Deeper and more profound,
+The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,7 ****
- The Way that can be told of is not the eternal Way;
- The name that can be named is not the eternal name.
  The Nameless is the origin of Heaven and Earth;
! The Named is the mother of all things.
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
--- 1,6 ----
  The Nameless is the origin of Heaven and Earth;
! The named is the mother of all things.
! 
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
***************
*** 9,11 ****
--- 8,13 ----
  The two are the same,
  But after they are produced,
    they have different names.
+ They both may be called deep and profound.
+ Deeper and more profound,
+ The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,7 ****
- The Way that can be told of is not the eternal Way;
- The name that can be named is not the eternal name.
  The Nameless is the origin of Heaven and Earth;
! The Named is the mother of all things.
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
--- 1,6 ----
  The Nameless is the origin of Heaven and Earth;
! The named is the mother of all things.
! 
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
***************
*** 9,11 ****
--- 8,13 ----
  The two are the same,
  But after they are produced,
    they have different names.
+ They both may be called deep and profound.
+ Deeper and more profound,
+ The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,11 ****
- The Way that can be told of is not the eternal Way;
- The name that can be named is not the eternal name.
  The Nameless is the origin of Heaven and Earth;
! The Named is the mother of all things.
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
    so we may see their outcome.
  The two are the same,
  But after they are produced,
!   they have different names.
\ No newline at end of file
--- 1,13 ----
  The Nameless is the origin of Heaven and Earth;
! The named is the mother of all things.
! 
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
    so we may see their outcome.
  The two are the same,
  But after they are produced,
!   they have different names.
! They both may be called deep and profound.
! Deeper and more profound,
! The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,11 ****
- The Way that can be told of is not the eternal Way;
- The name that can be named is not the eternal name.
  The Nameless is the origin of Heaven and Earth;
! The Named is the mother of all things.
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
    so we may see their outcome.
  The two are the same,
  But after they are produced,
!   they have different names.
\ No newline at end of file
--- 1,13 ----
  The Nameless is the origin of Heaven and Earth;
! The named is the mother of all things.
! 
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
    so we may see their outcome.
  The two are the same,
  But after they are produced,
!   they have different names.
! They both may be called deep and profound.
! Deeper and more profound,
! The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
1,2d0
< The Way that can be told of is not the eternal Way;
< The name that can be named is not the eternal name.
4c2,3
< The Named is the mother of all things.
---
> The named is the mother of all things.
> 
11a11,13
> They both may be called deep and profound.
> Deeper and more profound,
> The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
1,2d0
< The Way that can be told of is not the eternal Way;
< The name that can be named is not the eternal name.
4c2,3
< The Named is the mother of all things.
---
> The named is the mother of all things.
> 
11a11,13
> They both may be called deep and profound.
> Deeper and more profound,
> The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
1,2d0
< The Way that can be told of is not the eternal Way;
< The name that can be named is not the eternal name.
4c2,3
< The Named is the mother of all things.
---
> The named is the mother of all things.
> 
11c10,13
<   they have different names.
\ No newline at end of file
---
>   they have different names.
> They both may be called deep and profound.
> Deeper and more profound,
> The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
1,2d0
< The Way that can be told of is not the eternal Way;
< The name that can be named is not the eternal name.
4c2,3
< The Named is the mother of all things.
---
> The named is the mother of all things.
> 
11c10,13
<   they have different names.
\ No newline at end of file
---
>   they have different names.
> They both may be called deep and profound.
> Deeper and more profound,
> The door of all subtleties!
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
--- A
+++ B
@@ -1,7 +1,6 @@
-The Way that can be told of is not the eternal Way;
-The name that can be named is not the eternal name.
 The Nameless is the origin of Heaven and Earth;
-The Named is the mother of all things.
+The named is the mother of all things.
+
 Therefore let there always be non-being,
   so we may see their subtlety,
 And let there always be being,
@@ -9,3 +8,6 @@
 The two are the same,
 But after they are produced,
   they have different names.
+They both may be called deep and profound.
+Deeper and more profound,
+The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,7 ****
- The Way that can be told of is not the eternal Way;
- The name that can be named is not the eternal name.
  The Nameless is the origin of Heaven and Earth;
! The Named is the mother of all things.
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
--- 1,6 ----
  The Nameless is the origin of Heaven and Earth;
! The named is the mother of all things.
! 
  Therefore let there always be non-being,
    so we may see their subtlety,
  And let there always be being,
***************
*** 9,11 ****
--- 8,13 ----
  The two are the same,
  But after they are produced,
    they have different names.
+ They both may be called deep and profound.
+ Deeper and more profound,
+ The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
1,2d0
< The Way that can be told of is not the eternal Way;
< The name that can be named is not the eternal name.
4c2,3
< The Named is the mother of all things.
---
> The named is the mother of all things.
> 
11a11,13
> They both may be called deep and profound.
> Deeper and more profound,
> The door of all subtleties!
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
--- A
+++ B
@@ -1,2 +1 @@
 foo
-bar
\ No newline at end of file
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
*** A
--- B
***************
*** 1,2 ****
  foo
- bar
\ No newline at end of file
--- 1 ----
----8<--------8<--------8<--------8<--------8<--------8<--------8<----
2d1
< bar
\ No newline at end of file
#for my $style (@styles)
#  {
#  skip "Text::Diff > 0.35 required", 1
#      if $Text::Diff::VERSION <= 0.35;
#  my $patch  = diff( \$t1, \$t2, { STYLE => $style } );
#  my $result = patch( $t1, $patch, { STYLE => $style } );
#  ok( $result eq $t2, "patch $style (single no-nl lines)" );
#  }

sub TRACE {}
sub DUMP {}
