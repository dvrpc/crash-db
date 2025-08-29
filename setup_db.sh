#!/usr/bin/env bash

# Describe how to use this script.
usage="
Usage:
$(basename $0) --pa --nj --roads [ --reset ] | --usage

--pa: Import PA data.
--nj: Import NJ data.
--roads: Import NJ road network data.
--reset: Reset database (drop and recreate all objects), by state.
--dump: Dump existing database to file.
--download-pa: Download PA crash data using pa_start_year and pa_end_year from .env
--download-nj: Download and pre-process NJ crash data using nj_start_year and nj_end_year from .env
--download-roads: Download NJ road network shapefile
--usage: Show usage (this message) and exit. Other options will be ignored.

"

# Bring in environment variables.
. .env

# `port` is a required env var; exit it not set.
if [[ -z "${port}" ]]; then
  echo "Expected environment variable 'port' not found or doesn't have a value; please set it in a .env file." >&2
  exit
fi

# Use db (name) from .env or a default value.
if [[ -z "${db}" ]]; then
  db="crash"
fi

# Create database, ignoring error if it already exists.
psql -p "${port}" -c "create database ${db}" &>/dev/null

# Create pgtap extension (for testing).
psql -p "${port}" -c "create extension if not exists pgtap"

# Use user_data_dir from .env or a default value.
if [[ -z "${user_data_dir}" ]]; then
  user_data_dir="/tmp/crash-data"
fi

# Use postgres_data_dir from .env or a default value.
if [[ -z "${postgres_data_dir}" ]]; then
  postgres_data_dir="/var/lib/postgresql"
fi

# Exit if at least one option/argument wasn't provided.
if [[ ${#} < 1 ]]; then
  echo "At least one option required. Quitting."
  echo "${usage}"
  exit 1
fi

pa=false
nj=false
roads=false
reset=false
download_pa=false
download_nj=false
download_roads=false

# Parse and handle command line options.
while [[ $# -gt 0 ]]; do
  case $1 in
    --usage)
      echo "${usage}"
      exit
      ;;
    --reset)
      reset=true
      shift
      ;;
    --pa)
      pa=true
      # Check that start/end year env vars are set.
      if [[ -z "${pa_start_year}" ]]; then
        echo "Please include a value for 'pa_start_year' in the .env file."
        exit 1
      fi
      if [[ -z "${pa_end_year}" ]]; then
        echo "Please include a value for 'pa_end_year' in the .env file."
        exit 1
      fi
      # Check if start year too early.
      if test $((pa_start_year)) -lt 2005; then
        echo "${pa_start_year} is out of the bounds of the data. The earliest year available for PA is 2005."
        exit 1
      fi
      shift
      ;;
    --nj)
      nj=true
      # Check that start/end year env vars are set.
      if [[ -z "${nj_start_year}" ]]; then
        echo "Please include a value for 'nj_start_year' in the .env file."
        exit 1
      fi
      if [[ -z "${nj_end_year}" ]]; then
        echo "Please include a value for 'nj_end_year' in the .env file."
        exit 1
      fi
      # Check if start year too early.
      if test $((nj_start_year)) -lt 2006; then
        echo "${nj_start_year} is out of the bounds of the data. The earliest year available for NJ is 2006."
        exit 1
      fi
      shift
      ;;
    --dump)
      pg_dump -O -p "${port}" "${db}" > "data/crash_$(date +%F_%I-%M).dump"
      exit 0
      ;;
    --download-pa)
      download_pa=true
      # Check that start/end year env vars are set.
      if [[ -z "${pa_start_year}" ]]; then
        echo "Please include a value for 'pa_start_year' in the .env file."
        exit 1
      fi
      if [[ -z "${pa_end_year}" ]]; then
        echo "Please include a value for 'pa_end_year' in the .env file."
        exit 1
      fi
      shift
      ;;
    --download-nj)
      download_nj=true
      # Check that start/end year env vars are set.
      if [[ -z "${nj_start_year}" ]]; then
        echo "Please include a value for 'nj_start_year' in the .env file."
        exit 1
      fi
      if [[ -z "${nj_end_year}" ]]; then
        echo "Please include a value for 'nj_end_year' in the .env file."
        exit 1
      fi
      shift
      ;;
    --roads)
      roads=true
      shift
      ;;
    --download-roads)
      download_roads=true
      shift
      ;;
    *)
      echo "Invalid option $1. Quitting."
      echo "${usage}"
      exit 1
      ;;    
  esac
done

# Check if at least one action was specified
if test ${pa} = false && test ${nj} = false && test ${roads} = false && test ${download_pa} = false && test ${download_nj} = false && test ${download_roads} = false ; then
  echo "You must choose at least one action. Quitting."
  echo "${usage}"
  exit
fi

# Handle download actions first
if test ${download_pa} = true ; then
  echo "Downloading PA crash data..."
  cd src/utils && ./pa_download_data.sh && cd ../..
fi

# Copy data files in data/ to location accessible by server, for easier use in COPY, which
# requires absolute paths/certain permissions.
mkdir -p "${user_data_dir}/pa"
mkdir -p "${user_data_dir}/nj"
mkdir -p "${user_data_dir}/nj/roads"
cp -r data/pa/*.csv "${user_data_dir}/pa" 2>/dev/null || true
cp -r data/nj/*.txt "${user_data_dir}/nj/" 2>/dev/null || true
cp -r data/nj/roads/* "${user_data_dir}/nj/roads/" 2>/dev/null || true

if test ${download_nj} = true ; then
  echo "Downloading NJ crash data..."
  cd src/utils && ./nj_download_data.sh && cd ../..
  echo "Pre-processing NJ data files..."
  cd src/utils && user_data_dir="${user_data_dir}" ./nj_pre_process_files.sh && cd ../..
fi

if test ${download_roads} = true ; then
  echo "Downloading NJ road network..."
  cd src/utils && ./nj_download_roads.sh && cd ../..
fi

# If only downloading, exit here
if test ${pa} = false && test ${nj} = false && test ${roads} = false ; then
  echo "Download complete."
  exit
fi

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


  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -v pa_start_year="${pa_start_year}" -v pa_end_year="${pa_end_year}" -f src/init_vars.sql -f src/pa/init_vars.sql -f src/pa.sql
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

  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -v nj_start_year="${nj_start_year}" -v nj_end_year="${nj_end_year}" -f src/init_vars.sql -f src/nj/init_vars.sql -f src/nj.sql
fi

if [[ $roads = true ]]; then
  if [[ $reset = true ]]; then
    read -p "Are you sure want to reset the NJ roads table? (Press y to reset it, any other key to abort.) " -n 1 -r
    echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        psql -qb -p "${port}" -d "${db}" -c "DROP TABLE IF EXISTS nj_roads;"
      else
        echo 'Aborting.'
        exit
      fi
  fi

  # Use the roads download script with --import flag
  cd src/utils && ./nj_download_roads.sh --import && cd ../..
fi  
