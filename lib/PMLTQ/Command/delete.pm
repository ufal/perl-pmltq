package PMLTQ::Command::delete;
<<<<<<< HEAD
our $AUTHORITY = 'cpan:MATY';
$PMLTQ::Command::delete::VERSION = '1.2.3';
=======
our $AUTHORITY = 'cpan:MICHALS';
$PMLTQ::Command::delete::VERSION = '1.1.0';
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c
# ABSTRACT: Deletes the treebank from database

use PMLTQ::Base 'PMLTQ::Command';

has usage => sub { shift->extract_usage };

sub run {
  my $self   = shift;
  my $config = $self->config;

  my $dbh = $self->sys_db;
  $dbh->do("DROP DATABASE \"$config->{db}->{name}\";") or die $dbh->errstr;
  $dbh->disconnect;
}


1;

__END__

=pod

=encoding UTF-8

=head1 NAME

PMLTQ::Command::delete - Deletes the treebank from database

=head1 VERSION

<<<<<<< HEAD
version 1.2.3
=======
version 1.1.0
>>>>>>> 8de022e02ca25a48172558767e8e4ea04fb89b1c

=head1 SYNOPSIS

  pmltq delete <treebank_config>

=head1 DESCRIPTION

Delete the treebank from database.

=head1 OPTIONS

=head1 PARAMS

=over 5

=item B<treebank_config>

Path to configuration file. If a treebank_config is --, config is readed from STDIN.

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
