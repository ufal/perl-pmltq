#!/bin/bash

. "$(dirname "$0")"/postgres_config.sh

if [ $host != 'localhost' ] 
then 
  echo "ERROR host should be 'localhost' !!!"
  exit 0
fi

echo -n "dropping user '$user' with all his databases :"
dblist=`psql -c "SELECT d.datname FROM pg_database d  WHERE d.datdba in (SELECT oid FROM pg_roles WHERE rolname = '$user');"|tail -n +3|head -n -2| tr "\n" " "`
echo $dblist

for d in $dblist
do
  psql -c "DROP DATABASE $d;"
  echo $d
done

dropuser $user

