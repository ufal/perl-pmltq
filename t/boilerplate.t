#!perl -T

use 5.006;
use strict;
use warnings;
use Test::More tests => 43;

sub not_in_file_ok {
    my ($filename, %regex) = @_;
    open( my $fh, '<', $filename )
        or die "couldn't open $filename for reading: $!";

    my %violated;

    while (my $line = <$fh>) {
        while (my ($desc, $regex) = each %regex) {
            if ($line =~ $regex) {
                push @{$violated{$desc}||=[]}, $.;
            }
        }
    }

    if (%violated) {
        fail("$filename contains boilerplate text");
        diag "$_ appears on lines @{$violated{$_}}" for keys %violated;
    } else {
        pass("$filename contains no boilerplate text");
    }
}

sub module_boilerplate_ok {
    my ($module) = @_;
    not_in_file_ok($module =>
        'the great new $MODULENAME'   => qr/ - The great new /,
        'boilerplate description'     => qr/Quick summary of what the module/,
        'stub function definition'    => qr/function[12]/,
    );
}

TODO: {
  local $TODO = "Need to replace the boilerplate text";

  not_in_file_ok(README =>
    "The README is used..."       => qr/The README is used/,
    "'version information here'"  => qr/to provide version information/,
  );

  not_in_file_ok(Changes =>
    "placeholder date/time"       => qr(Date/time)
  );

  module_boilerplate_ok('lib/PMLTQ.pm');
  module_boilerplate_ok('lib/PMLTQ/PML2BASE.pm');
  module_boilerplate_ok('lib/PMLTQ/Grammar.pm');
  module_boilerplate_ok('lib/PMLTQ/ParserError.pm');
  module_boilerplate_ok('lib/PMLTQ/Grammar.pm');
  module_boilerplate_ok('lib/PMLTQ/SQLEvaluator.pm');
  module_boilerplate_ok('lib/PMLTQ/NG2PMLTQ.pm');
  module_boilerplate_ok('lib/PMLTQ/BtredEvaluator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/FSFileIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/CurrentFileIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/TreexFileIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/CurrentFilelistIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/TreexFilelistIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/CurrentTreeIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/CurrentFilelistTreesIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/TreeIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/SameTreeIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/TransitiveIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/OptionalIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/ChildnodeIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/DepthFirstPrecedesIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/DepthFirstFollowsIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/DepthFirstRangeIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/DescendantIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/DescendantIteratorWithBoundedDepth.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/ParentIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/AncestorIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/AncestorIteratorWithBoundedDepth.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/SiblingIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/SiblingIteratorWithDistance.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/PMLREFIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/MemberIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/OrderIterator.pm');
  module_boilerplate_ok('lib/PMLTQ/CGI.pm');
  module_boilerplate_ok('lib/PMLTQ/Common.pm');
  module_boilerplate_ok('lib/PMLTQ/Planner.pm');
  module_boilerplate_ok('lib/PMLTQ/TypeMapper.pm');
  module_boilerplate_ok('lib/PMLTQ/ParserError.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/Iterator.pm');
  module_boilerplate_ok('lib/PMLTQ/Relation/SimpleListIterator.pm');


}

