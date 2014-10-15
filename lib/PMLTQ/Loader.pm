package PMLTQ::Loader;

# Module loader for L<PMLTQ::Relation|PMLTQ::Relation>s inspired by L<Mojo::Loader>

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