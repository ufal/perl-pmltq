package PMLTQ::Command::webtreebank;

# ABSTRACT: GET actions on treebanks on the web

use PMLTQ::Base 'PMLTQ::Command';
use JSON;
use YAML::Tiny;
use Hash::Merge 'merge';

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;
  my $subcommand = shift;
  my $config = $self->config;
  unless($subcommand){
    die "Subcommand must be set." 
  }
  my $ua = $self->ua;
  $self->login($ua);
  my $json = JSON->new;

  if($subcommand eq 'list'){
    my $treebanks = $self->get_all_treebanks($ua);
    print join("\n",
             map {
              my $tb = $_; 
              join("\t",
                map {$tb->{$_}} split(/,/,$config->{info}->{fields}) )} @$treebanks
            ),"\n";
  } elsif($subcommand eq 'single') {
    my $treebank = $self->get_treebank($ua);
    print YAML::Tiny->new(merge(
                                merge( $config, $self->user2admin_format($treebank)),
                                {test_query => {
                                  result_dir => 'query_results/'.$treebank->{name},
                                  queries => $self->get_test_queries($treebank)
                                  }}
                                )
                         )->write_string;
  }
}

=head1 SYNOPSIS

  pmltq webtreebank <api_url>

=head1 DESCRIPTION

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<api_url>

Url to pmltq service

=back

=head1 EXAMPLES

=over 5

=item Creates and executes simple queries on all treebanks on web

for tb in `./script/pmltq webtreebank list`; do  echo "$tb"; ./script/pmltq webtreebank single --treebank_id=$tb | ./script/pmltq webverify -c --; sleep 60; done

=back

=cut

1;
