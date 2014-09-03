package PMLTQ;

# ABSTRACT: Query engine and query language for trees in PML format

=head1 DESCRIPTION

This is an implementation of a PML-TQ search engine (CGI module) and a
command-line client. A graphical client for PML-TQ is part of the tree editor
TrEd (http://ufal.mff.cuni.cz/tred).

=cut

use strict;
use warnings;

use File::Basename 'dirname';
use File::Spec ();

my $home = File::Spec->catdir(dirname(__FILE__), __PACKAGE__);

sub home { $home }

1;