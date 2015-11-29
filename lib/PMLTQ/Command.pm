package PMLTQ::Command;

# ABSTRACT: Command base class

use PMLTQ::Base -base;

use DBI;
use File::Slurp;
use Pod::Usage 'pod2usage';

has config => sub { die 'Command has no configuration'; };

has usage => sub {'Usage: '};

has term => sub {
  require Term::UI;
  require Term::ReadLine;
  Term::ReadLine->new('pmltq');
};

has term_encoding => sub {
  require Term::Encoding;
  Term::Encoding::get_encoding();
};

sub run {
  die 'Override by parent class';
}

sub extract_usage {
  my $self = shift;

  open my $handle, '>', \my $output;
  pod2usage( -exitval => 'NOEXIT', -input => (caller)[1], -output => $handle );
  $output =~ s/\n$//;

  return $output;
}

sub help {
  print shift->usage;
}

sub _db_connect {
  my ( $database, $host, $port, $user, $password ) = @_;

<<<<<<< HEAD
  my $dbh = DBI->connect( 'DBI:' . $driver . ':database=' . $database . ';host=' . $host . ';port=' . $port,
=======
  my $dbh = DBI->connect( 'DBI:Pg:dbname=' . $database . ';host=' . $host . ';port=' . $port,
>>>>>>> remove driver and syntax from commands and tests
    $user, $password, { RaiseError => 1, PrintError => 1 } )
    or die "Unable to connect to database!\n$DBI::errstr\n";
  return $dbh;
}

sub db {
  my $self = shift;

  my $db = $self->config->{db};
  return _db_connect( $db->{name}, $db->{host}, $db->{port}, $db->{user}, $db->{password} );
}

sub sys_db {
  my $self = shift;

  my $config = $self->config;
  my $db     = $config->{db};
  my $sys_db = $config->{sys_db};

  unless ( ref $sys_db ) {
    $sys_db = { name => $sys_db };
  }

  $sys_db->{$_} = $db->{$_} for ( grep { !defined $sys_db->{$_} } qw/user password/ );

  return _db_connect( $sys_db->{name}, $db->{host}, $db->{port}, $sys_db->{user}, $sys_db->{password} );
}

sub run_sql_from_file {
  my ( $self, $file, $dir, $dbh ) = @_;

  my $sqlfile = File::Spec->catfile( $dir, $file );
  my $sql = read_file($sqlfile);

  print STDERR "RUNNING SQL FROM $sqlfile\n";
  if ( $file =~ m/.ctl/ and my $copy = () = $sql =~ m/(COPY .*? FROM *?["'].*?["'])/g ) {
    die "More COPY commands than one in file is not supported.\n\n$sql\n" if $copy > 1;
    $sql =~ s/(COPY .*? FROM) *?["'](.*?)["']/$1 STDIN/;
    my $dump_file = File::Spec->catfile( $dir, $2 );
    eval {
      $dbh->do($sql);
      open my $fh, '<', "$dump_file" or die "Can't open $dump_file: $!";
      while ( my $data = <$fh> ) {    # Do not load whole file, but process it line by line
        next unless $data;
        $dbh->pg_putcopydata("$data");
      }
      $dbh->pg_putcopyend();
    };
    warn $@ if $@;
  }
  else {
    my @statements = split /\n\n/, $sql;
    for my $s (@statements) {
      eval { $dbh->do($s); };
      print STDERR "SQL FAILED:\t$s\n\t$@\n" if $@;
    }
  }
}

# Borrowed from https://metacpan.org/release/Dist-Zilla
sub prompt_str {
  my ( $self, $prompt, $arg ) = @_;

  $arg ||= {};
  my $default = $arg->{default};
  my $check   = $arg->{check};

  require Encode;
  my $term_encoding = $self->term_encoding;

  my $encode
    = $term_encoding
    ? sub { Encode::encode( $term_encoding, shift, Encode::FB_CROAK() ) }
    : sub {shift};
  my $decode
    = $term_encoding
    ? sub { Encode::decode( $term_encoding, shift, Encode::FB_CROAK() ) }
    : sub {shift};

  my $input_bytes = $self->term->get_reply(
    prompt => $encode->($prompt),
    allow  => $check || sub { defined $_[0] and length $_[0] },
    ( defined $default
      ? ( default => $encode->($default) )
      : ()
    ),
  );

  my $input = $decode->($input_bytes);
  chomp $input;

  return $input;
}

sub prompt_yn {
  my ( $self, $prompt, $arg ) = @_;
  $arg ||= {};
  my $default = $arg->{default};

  my $input = $self->term->ask_yn(
    prompt => $prompt,
    ( defined $default ? ( default => $default ) : () ),
  );

  return $input;
}

1;
