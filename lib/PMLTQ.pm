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
use File::ShareDir 'dist_dir';

my $home_dir = File::Spec->catdir(dirname(__FILE__), __PACKAGE__);
my $local_shared_dir = File::Spec->catdir(dirname(__FILE__), File::Spec->updir, 'share');
my $shared_dir = eval {	dist_dir(__PACKAGE__) };

# Assume installation
if (-d $local_shared_dir or !$shared_dir) {
  $shared_dir = $local_shared_dir;
}

sub home { $home_dir }

sub shared_dir { $shared_dir }

sub resources_dir { File::Spec->catdir($shared_dir, 'resources') }

1;
