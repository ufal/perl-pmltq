package PMLTQ;
# ABSTRACT: Query engine and query language for trees in PML format also know as PML-TQ

use strict;
use warnings;

use File::Basename 'dirname';
use File::Spec ();

BEGIN {
  our $VERSION = '0.7.10';
}

my $home = File::Spec->catdir(dirname(__FILE__), __PACKAGE__);

sub home { $home }

=head1 DESCRIPTION

This is an implementation of a PML-TQ search engine (CGI module) and a
command-line client. A graphical client for PML-TQ is part of the tree editor
TrEd (http://ufal.mff.cuni.cz/tred).

=cut

1;

__END__

=head1 QUICK START

=head2 TODO

Reuse stuff from old the README file

Include PMLTQ::Api and PMLTQ::Web

