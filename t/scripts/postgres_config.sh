

configfile='../treebanks/pdt20_sample_small/config.yml'
user=`grep '^\s*user:' $configfile|head -n1 | sed  -e 's/^\s*user:\s*"\?\([^"\s]*\)"\?/\1/'`
pass=`grep '^\s*password:' $configfile|head -n1 | sed  -e 's/^\s*password:\s*"\?\([^"\s]*\)"\?/\1/'`
port=`grep '^\s*port:' $configfile|head -n1 | sed  -e 's/^\s*port:\s*"\?\([^"\s]*\)"\?/\1/'`
host=`grep '^\s*host:' $configfile|head -n1 | sed  -e 's/^\s*host:\s*"\?\([^"\s]*\)"\?/\1/'`

