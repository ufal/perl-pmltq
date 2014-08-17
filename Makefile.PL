use 5.006;
use utf8;
use strict;
use warnings;
use ExtUtils::MakeMaker 6.46;

my $preop =
    'perldoc -uT $(VERSION_FROM) | tee $(DISTVNAME)/README.pod > README.pod;' .
    'pod2text -u README.pod | tee $(DISTVNAME)/README > README';

WriteMakefile(
    NAME                => 'PMLTQ',
    AUTHOR              => [
      q(Petr Pajas <pajas@ufal.mff.cuni.cz>),
      q(Jan Štěpánek <stepanek@ufal.mff.cuni.cz>),
      q(Michal Sedlák <sedlak@ufal.mff.cuni.cz>)
                            ],
    VERSION_FROM        => 'lib/PMLTQ.pm',
    ABSTRACT_FROM       => 'lib/PMLTQ.pm',
    LICENSE             => 'perl',
    EXE_FILES => ['script/pmltq', 'script/pmltq_http', 'script/pml2base'],  ### A reference to an array of executable files. The files will be copied to the INST_EXE directory. A make realclean command will delete them from there again
    PREREQ_PM => {
        'Test::More' => 0,
    },
    META_MERGE        => {
      no_index => { file => ['PMLTQ/Grammar.pm']},
      'meta-spec' => { version => 2 },
      resources => {
        homepage    => 'http://ufal.mff.cuni.cz/pmltq/',
        bugtracker  => {
          web    => 'https://github.com/ufal/perl-pmltq/issues',
          mailto => 'pmltq@ufal.mff.cuni.cz',
        },
        repository  => {
          url  => 'git://github.com/ufal/perl-pmltq-server.git',
          web  => 'https://github.com/ufal/perl-pmltq',
          type => 'git',
        },
      },
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', PREOP => $preop },
    clean               => { FILES => 'PMLTQ-*' },
);
#sudo rm -rf /usr/local/share/perl/5.14.2/PMLTQ/
#sudo rm /usr/local/man/man3/PMLTQ::*
