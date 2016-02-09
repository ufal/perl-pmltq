package PMLTQ::Command::init;
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Command::init::VERSION = '1.2.1';
# ABSTRACT: Initialize empty database

use PMLTQ::Base 'PMLTQ::Command';
use File::Spec;
use File::Basename 'dirname';
use PMLTQ::PML2BASE;
use PMLTQ::Common;
use Treex::PML::Factory;
use YAML::Tiny;
use List::Util qw/none first/;

has usage => sub { shift->extract_usage };

my %known_relations = (
  'a-align-links/counterpart.rf'         => 'a-node',
  'a-node/p_terminal.rf'                 => 'p-terminal',
  'a-root/ptree.rf'                      => 'p-nonterminal',
  'apreds/LM/target.rf'                  => 'node',
  'local_event/author'                   => 'user',
  'n-node/a.rf'                          => 'a-node',
  'nonterminal/coindex.rf'               => 'nonterminal',
  'problem/author'                       => 'user',
  'secedge/idref'                        => 'nonterminal',
  'st-node/tnode.rfs'                    => 't-node',
  't-a/aux.rf'                           => 'a-node',
  't-a/lex.rf'                           => 'a-node',
  't-align-links/counterpart.rf'         => 't-node',
  't-bridging-link/target_node.rf'       => 't-node',
  't-coref_text-link/target_node.rf'     => 't-node',
  't-discourse-link/a-connectors.rf'     => 'a-node',
  't-discourse-link/all_a-connectors.rf' => 'a-node',
  't-discourse-link/t-connectors.rf'     => 't-node',
  't-discourse-link/target_node.rf'      => 't-node',
  't-node/compl.rf'                      => 't-node',
  't-node/coref_gram.rf'                 => 't-node',
  't-node/coref_text.rf'                 => 't-node',
  't-node/original_parent.rf'            => 't-node',
  't-node/src_tnode.rf'                  => 't-node',
  't-node/val_frame.rf'                  => 'v-frame',
  't-root/atree.rf'                      => 'a-root',
  't-root/src_tnode.rf'                  => 't-node',
  'terminal/coindex.rf'                  => 'nonterminal',
  'valency_lexicon/owner'                => 'user',
);

sub run {
  my $self = shift;

  my $config = $self->config;

  unless (@_) {
    say 'Specify at least one schema file';
    return 0;
  }

  my ( @layers, @schemas );

  for my $schema_file (@_) {
    unless ( -f $schema_file ) {
      my $in_resources = File::Spec->catfile( $config->{resources}, $schema_file );
      unless ( -f $in_resources ) {
        say "Schema file '$schema_file' not found";
        return 0;
      }
      $schema_file = $in_resources;
    }

    push @schemas, my $schema = Treex::PML::Factory->createPMLSchema( { filename => $schema_file } );
    PMLTQ::PML2BASE::init();
    my $refs = PMLTQ::PML2BASE::complete_schema_pmlref_list($schema);
    PMLTQ::PML2BASE::destroy();

    push @layers, {
      name       => $schema->get_root_name,
      data       => '<change this to point to files relative to the data_dir>',
      references => {%$refs}
      };
  }

  my $resources_dir =
      @schemas > 1
    ? $self->common_prefix( map { dirname( File::Spec->canonpath( $_->get_url ) ) } @schemas )
    : dirname( $schemas[0]->get_url );

  $_->set_url( File::Spec->abs2rel( $_->get_url, $resources_dir ) ) for (@schemas);

  # resolve refs
  $self->try_resolve_references( \@layers, \@schemas );

  my $treebank_title = $self->prompt_str( 'Full treebank title', { default => 'Prague Dependency Treebank 3.0' } );

  my $treebank_id = join '', grep {/[a-z0-9]/} map { substr $_, 0, 1 } split /[^a-z0-9]+/, lc $treebank_title;
  $treebank_id = $self->prompt_str(
    'Treebank ID (can only contain lowercase letters, numbers and underscores)', {
      default => $treebank_id,
      check   => sub { defined $_[0] and length $_[0] and $_[0] =~ m/^[a-z0-9_]+$/ }
    }
  );

  my $yaml = YAML::Tiny->new(
    {
      treebank_id => $treebank_id,
      title       => $treebank_title,
      resources   => $resources_dir,
      layers      => \@layers
    }
  );

  say $yaml->write_string;

  my $save = $self->prompt_yn( 'Save?', { default => 0 } );

  if ($save) {
    my $filename = $self->prompt_str(
      'Save as', {
        default => 'pmltq.yml'
      }
    );
    $yaml->write($filename);
  }
}

sub common_prefix {
  my $self  = shift;
  my @paths = @_;
  my %prefixes;

  for (@_) {
    my @parts  = File::Spec->splitdir($_);
    my $prefix = shift @parts;
    ++$prefixes{$prefix};
    ++$prefixes{ $prefix = File::Spec->catdir( $prefix, $_ ) } for (@parts);
  }
  return first { $prefixes{$_} == @paths } reverse sort keys %prefixes;
}

sub try_resolve_references {
  my ( $self, $layers, $schemas ) = @_;

  my %type_map;

  for my $schema (@$schemas) {
    $schema->for_each_decl(
      sub {
        my $decl = shift;
        my $is_node = ( $decl->get_role || '' ) eq '#NODE';
        return unless $is_node;

        my $type = PMLTQ::Common::DeclPathToQueryType( $decl->get_decl_path );
        $type_map{$type} = $schema;
      }
    );
  }

  for my $layer (@$layers) {
    my $refs = $layer->{references};
    for my $path ( grep { $known_relations{$_} } keys %$refs ) {
      my $type   = $known_relations{$path};
      my $schema = $type_map{$type};
      next unless $schema;    # check if type exists at all

      my $is_other_schema = $schema->get_root_name ne $layer->{name};
      $refs->{$path} = ( $is_other_schema ? $schema->get_root_name . ':' : '' ) . $type;

      if ($is_other_schema) {    # add to related schemas
        $layer->{'related-schema'} = [] unless $layer->{'related-schema'};
        my $schema_url = $schema->get_url->as_string;
        push @{ $layer->{'related-schema'} }, $schema_url
          if none { $schema_url eq $_ } @{ $layer->{'related-schema'} };
      }
    }
  }
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Command::init - Initialize empty database

=head1 VERSION

version 1.2.1

=head1 SYNOPSIS

  pmltq init --resources='/path/to/schemas' schema1 schema2

=head1 DESCRIPTION

Initialize configuration file based on given schemas.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<resources>

Optional path to schema files. Standard configuration value.

=item B<schemas>

List of schemas to generate the configuration from

=back

=head1 AUTHORS

=over 4

=item *

Petr Pajas <pajas@ufal.mff.cuni.cz>

=item *

Jan Štěpánek <stepanek@ufal.mff.cuni.cz>

=item *

Michal Sedlák <sedlak@ufal.mff.cuni.cz>

=item *

Matyáš Kopp <matyas.kopp@gmail.com>

=back

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 by Institute of Formal and Applied Linguistics (http://ufal.mff.cuni.cz).

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
