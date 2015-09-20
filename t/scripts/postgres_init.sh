#!/bin/bash

. "$(dirname "$0")"/postgres_config.sh

if [ $host != 'localhost' ] 
then 
  echo "ERROR host should be 'localhost' !!!"
  exit 0
fi

echo "creating user '$user' with password '$pass'"
psql -c "CREATE ROLE $user WITH CREATEDB LOGIN PASSWORD '$pass';"

