package PMLTQ::Loader;

# ABSTRACT: Module loader for L<PMLTQ::Relation|PMLTQ::Relation>s inspired by L<Mojo::Loader>

=head1 SYNOPSIS

  use PMLTQ::Loader qw/find_modules load_class/;
  for my $module (find_modules('PMLTQ::Relation')) {
    print "Loading module: '$module'\n";
    load_class($module);
  }

=head1 DESCRIPTION

L<PMLTQ::Loader|PMLTQ::Loader> is a class loader and a part of the module
framework allowing users to define their own PML-TQ relations.

=cut

use PMLTQ::Base -strict;

use Exporter 'import';
use File::Basename 'fileparse';
use File::Spec;

our @EXPORT_OK
  = qw(find_modules load_class);

sub class_to_path { join '.', join('/', split /::|'/, shift), 'pm' }

sub load_class {
  my ($class) = @_;

  # Check module name
  return undef if !$class || $class !~ /^\w(?:[\w:']*\w)?$/;

  # Loaded
  return 1 if $class->can('new') || eval {
    my $file = class_to_path($class);
    require $file;
    1;
  };

  # Exists
  return undef if $@ =~ /^Can't locate \Q@{[class_to_path $class]}\E in \@INC/;

  # Real error
  die $@;
}

sub find_modules {
  my ($ns) = @_;

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
