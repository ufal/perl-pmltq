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
    EXE_FILES => ['script/pmltq', 'script/pmltq_http', 'script/pml2base'],  ### A reference to an array of executable files. The files will be copied to the INST_EXE directory. A make realclean command will delete them from there again
    INST_EXE => 'script', ### Directory where executable scripts should be staged during running of make . Defaults to ./blib/bin , just to have a dummy location during testing. make install will copy the files in INST_EXE to INSTALLBIN .
    INSTALLBIN => 'xxx', ## Used by make install , which copies files from INST_EXE to this directory.
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'PMLTQ-*' },
);
#sudo rm -rf /usr/local/share/perl/5.14.2/PMLTQ/
#sudo rm /usr/local/man/man3/PMLTQ::*