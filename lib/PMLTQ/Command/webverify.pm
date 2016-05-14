package PMLTQ::Command::webverify;

# ABSTRACT: Check if treebank is setted in web interface

use PMLTQ::Base 'PMLTQ::Command';

has usage => sub { shift->extract_usage };

sub run {
  my $self = shift;
  my $ua = $self->ua;
  $self->login($ua);
  my $data;
  my $json = JSON->new;
  my $url = URI::WithBase->new('/',$self->config->{web_api}->{url});
  $url->path_segments('api','admin', 'treebanks');
  (undef,$data) = $self->request($ua,'GET',$url->abs->as_string);
  my ($treebank) = grep {$_->{name} eq $self->config->{treebank_id}} @{ $data // []};
  print $treebank ? $json->pretty->encode($treebank) : "";
}

=head1 SYNOPSIS

  pmltq webverify <treebank_config>

=head1 DESCRIPTION

Check if treebank is setted in web interface.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

=back

=cut

1;
