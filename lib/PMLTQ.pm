package PMLTQ;
our $AUTHORITY = 'cpan:MICHALS';
{
  $PMLTQ::VERSION = '0.8.3';
}

# ABSTRACT: Query engine and query language for trees in PML format


use strict;
use warnings;

use File::Basename 'dirname';
use File::Spec ();
use File::ShareDir 'dist_dir';

my $home_dir = File::Spec->catdir(dirname(__FILE__), __PACKAGE__);
my $shared_dir = eval {	dist_dir(__PACKAGE__) };

# Assume installation
unless ($shared_dir) {
	my $updir = File::Spec->updir();
	$shared_dir = File::Spec->catdir(dirname(__FILE__), $updir, 'share');	
}

sub home { $home_dir }

sub shared_dir { $shared_dir }

sub resources_dir { File::Spec->catdir($shared_dir, 'resources') }

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ - Query engine and query language for trees in PML format

=head1 VERSION

version 0.8.3

=head1 DESCRIPTION

This is an implementation of a PML-TQ search engine (CGI module) and a
command-line client. A graphical client for PML-TQ is part of the tree editor
TrEd (http://ufal.mff.cuni.cz/tred).

=head1 AUTHORS

=over 4

=item *

Petr Pajas <pajas@ufal.mff.cuni.cz>

=item *

Jan Štěpánek <stepanek@ufal.mff.cuni.cz>

=item *

Michal Sedlák <sedlak@ufal.mff.cuni.cz>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Institute of Formal and Applied Linguistics (http://ufal.mff.cuni.cz).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
