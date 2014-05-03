use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'PMLTQ',
    AUTHOR              => q{AUTHOR <AUTHOR@UFAL>},
    VERSION_FROM        => 'lib/PMLTQ.pm',
    ABSTRACT_FROM       => 'lib/PMLTQ.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    #PL_FILES            => {'lib/PMLTQ/generate_grammar.pl' => ' '}, ### nefunguje
    EXE_FILES => ['script/pmltq', 'script/pmltq_http', 'script/pmltq2base'],
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PMLTQ-*' },
);
#sudo rm -rf /usr/local/share/perl/5.14.2/PMLTQ/
#sudo rm /usr/local/man/man3/PMLTQ::*