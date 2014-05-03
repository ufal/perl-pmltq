#!perl -T

use Test::More tests => 41;

BEGIN {
    use_ok( 'PMLTQ' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::PML2BASE' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Grammar' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::ParserError' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Grammar' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::SQLEvaluator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::NG2PMLTQ' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::BtredEvaluator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::FSFileIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::CurrentFileIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::TreexFileIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::CurrentFilelistIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::TreexFilelistIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::CurrentTreeIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::CurrentFilelistTreesIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::TreeIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::SameTreeIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::TransitiveIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::OptionalIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::ChildnodeIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::DepthFirstPrecedesIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::DepthFirstFollowsIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::DepthFirstRangeIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::DescendantIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::DescendantIteratorWithBoundedDepth' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::ParentIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::AncestorIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::AncestorIteratorWithBoundedDepth' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::SiblingIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::SiblingIteratorWithDistance' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::PMLREFIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::MemberIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::OrderIterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::CGI' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Common' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Planner' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::TypeMapper' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::ParserError' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::Iterator' ) || print "Bail out!\n";
    use_ok( 'PMLTQ::Relation::SimpleListIterator' ) || print "Bail out!\n";
}

diag( "Testing PMLTQ $PMLTQ::VERSION, Perl $], $^X" );
