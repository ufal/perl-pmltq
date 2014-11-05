package PMLTQ::Loader;
our $AUTHORITY = 'cpan:MICHALS';
{
  $PMLTQ::Loader::VERSION = '0.8.3';
}

# ABSTRACT: Module loader for L<PMLTQ::Relation|PMLTQ::Relation>s inspired by L<Mojo::Loader>


use strict;
use warnings;
use File::Basename 'fileparse';
use File::Spec;

sub class_to_path { join '.', join('/', split /::|'/, shift), 'pm' }

sub load {
  my ($class, $module) = @_;
 
  # Check module name
  return 1 if !$module || $module !~ /^\w(?:[\w:']*\w)?$/;
 
  # Load
  return undef if $module->can('new') || eval "require $module; 1";
 
  # Exists
  return 1 if $@ =~ /^Can't locate \Q@{[class_to_path $module]}\E in \@INC/;
 
  # Real error
  die $@;
}
 
sub search {
  my ($class, $ns) = @_;
 
  my %modules;
  for my $directory (@INC) {
    next unless -d (my $path = File::Spec->catdir($directory, split(/::|'/, $ns)));
 
    # List "*.pm" files in directory
    opendir(my $dir, $path);
    for my $file (grep /\.pm$/, readdir $dir) {
      next if -d File::Spec->catfile(File::Spec->splitdir($path), $file);
      $modules{"${ns}::" . fileparse $file, qr/\.pm/}++;
    }
  }
 
  return keys %modules;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Loader - Module loader for L<PMLTQ::Relation|PMLTQ::Relation>s inspired by L<Mojo::Loader>

=head1 VERSION

version 0.8.3

=head1 SYNOPSIS

  use PMLTQ::Loader;
  for my $module (PMLTQ::Loader->search('PMLTQ::Relation')) {
    print "Loading module: '$module'\n";
    PMLTQ::Loader->load($module);
  }

=head1 DESCRIPTION

L<PMLTQ::Loader|PMLTQ::Loader> is a class loader and a part of the module
framework allowing users to define their own PML-TQ relations.

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
