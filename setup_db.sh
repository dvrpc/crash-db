#! /usr/bin/env bash

# Describe how to use this script.
usage="
Usage:
$(basename $0) -p -n [ -r ] | -u

-p: Import PA data.
-n: Import NJ data.
-r: Reset database (drop and recreate all objects), by state.
-u: Show usage (this message) and exit. Other options will be ignored.

e.g.
./setup_db.sh -p to import PA data
./setup_db.sh -nr to reset and import NJ data

"

# Bring in environment variables.
. .env

# `port` is a required env var; exit it not set.
if [[ -z "${port}" ]]; then
  echo "Expected environment variable 'port' not found or doesn't have a value; please set it in a .env file." >&2
  exit
fi

# Use db (name) from .env or a default value.
if ! test -v db; then
  db="crash"
fi

# Use user_data_dir from .env or a default value.
if ! test -v user_data_dir; then
  user_data_dir="/tmp/crash-data"
fi

# Use postgres_data_dir from .env or a default value.
if ! test -v postgres_data_dir; then
  postgres_data_dir="/var/lib/postgresql"
fi

# Exit if at least one option/argument wasn't provided.
if [[ ${#} < 1 ]]; then
  echo "At least one option required. Quitting."
  echo "${usage}"
  exit 1
fi

# Exit if an argument provided, rather than option.
if [[ "${1}" != -* ]]; then
  echo "This program does not take any arguments, only options. Quitting."
  echo "${usage}" 
  exit 1
fi

pa=false
nj=false
reset=false

# Parse and handle command line options.
while getopts ":unpr" opt; do
  case $opt in
    u)
      echo "${usage}"
      exit
      ;;
    r)
      reset=true
      ;;
    p)
      pa=true
      ;;
    n)
      nj=true
      ;;
    \?)
      echo "Invalid option -${OPTARG}. Quitting."
      echo "${usage}"
      exit 1
      ;;    
  esac
done

if test ${pa} = false && test ${nj} = false ; then
  echo "You must choose at least one state. Quitting."
  echo "${usage}"
  exit
fi

# Copy data files in data/ to location accessible by server, for easier use in COPY, which
# requires absolute paths/certain permissions.
# mkdir -p "${user_data_dir}"
# cp -r data/* "${user_data_dir}"

## Create custom domains.
psql -q -p "${port}" -d "${db}" < src/domains.sql

if [[ $pa = true ]]; then
  if [[ $reset = true ]]; then
    read -p "Are you sure want to reset the PA database? (Press y to reset it, any other key to abort.) " -n 1 -r
    echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        psql -p "${port}" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';"
        psql -qb -p "${port}" -d "${db}" -f src/pa/drop.sql
      else
        echo 'Aborting.'
        exit
      fi
  fi


  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -f src/init_vars.sql -f src/pa.sql
fi

if [[ $nj = true ]]; then
  if [[ $reset = true ]]; then
    read -p "Are you sure want to reset the NJ database? (Press y to reset it, any other key to abort.) " -n 1 -r
    echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        psql -qb -p "${port}" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';"
        psql -qb -p "${port}" -d "${db}" -f src/nj/drop.sql
      else
        echo 'Aborting.'
        exit
      fi
  fi

  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -f src/init_vars.sql -f src/nj.sql
fi  
