package PMLTQ::Relation::Treex;

use warnings;
use strict;

use PMLTQ::Relation::Treex::AEChildCIterator;
use PMLTQ::Relation::Treex::AEParentCIterator;
use PMLTQ::Relation::Treex::TEParentIterator;
use PMLTQ::Relation::Treex::AEParentIterator;
use PMLTQ::Relation::Treex::AEChildIterator;
use PMLTQ::Relation::Treex::TEChildIterator;

#
# This file implements the following user-defined relations for PML-TQ
#
# - eparentC, echildC - Slightly modified (skipping only coordinarion nodes) eparent/echild for a-layer
# - eparent (both t-layer and a-layer)
# - echild (both t-layer and a-layer)
#

sub AGetEParentsC {
  return shift->get_eparents({or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}

sub AGetEChildrenC {
  return shift->get_echildren({or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}

sub AGetEParents {
  return shift->get_eparents({dive => 'AuxCP', or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}

sub AGetEChildren {
  return shift->get_echildren({dive => 'AuxCP', or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}

sub TGetEChildren {
  return shift->get_echildren({or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}

sub TGetEParents {
  return shift->get_eparents({or_topological => 1, ignore_incorrect_tree_structure => 1, ordered => 1});
}



1;