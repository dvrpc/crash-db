#!/usr/bin/env bash

# Describe how to use this script.
usage="
Usage:
$(basename $0) [--download|--import|--reset] [pa] [nj] [--no-geometry] [--process-nj] | --usage

--download [pa] [nj]: Download specified state crash data.
--import [pa] [nj]: Import specified state data and generate geometry columns.
--reset [pa] [nj]: Reset database (drop and recreate all objects) for specified states.
--no-geometry: Skip geometry column generation and road network import.
--process-nj: Pre-process NJ crash data without downloading first.
--dump: Dump existing database to file.
--usage: Show usage (this message) and exit. Other options will be ignored.

Examples:
  $(basename $0) --import pa nj               # Import both PA and NJ data
  $(basename $0) --reset pa                   # Reset only PA database
  $(basename $0) --download nj                # Download only NJ data
  $(basename $0) --reset pa --no-geometry     # Reset only PA database, with no geometry

Note: Geometry generation is enabled by default. For NJ data, this automatically
downloads and imports the road network if not already present.
"

# Bring in environment variables.
. .env

# `port` is a required env var; exit if not set.
if [[ -z "${port}" ]]; then
  echo "Expected environment variable 'port' not found or doesn't have a value; please set it in a .env file." >&2
  exit 1
fi

# Use db (name) from .env or a default value.
if [[ -z "${db}" ]]; then
  db="crash"
fi

# Create database, ignoring error if it already exists.
psql -p "${port}" -c "create database ${db}" &>/dev/null

# If postgis extension doesn't exist on db, inform and exit.
postgis_check=$(psql -p "${port}" -d "${db}" -t -c "select count(extname) from pg_extension where extname='postgis'")

if [ ${postgis_check} = 0 ]; then
  echo "PostGIS extension not found. Attempting to create it..."
  if psql -p "${port}" -d "${db}" -c "CREATE EXTENSION postgis;" >/dev/null 2>&1; then
    echo "PostGIS extension created successfully."
  else
    echo "Failed to create PostGIS extension. Please install PostGIS and/or run as a superuser."
    echo "${usage}"
    exit 1
  fi
fi

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
reset=false
process_nj=false
geometry=true
import_mode=false
download_mode=false
reset_mode=false

# Parse and handle command line options.
while [[ $# -gt 0 ]]; do
  case $1 in
    --usage)
      echo "${usage}"
      exit
      ;;
    --import)
      import_mode=true
      shift
      # Parse state arguments
      while [[ $# -gt 0 ]] && [[ $1 != --* ]]; do
        case $1 in
          pa)
            pa=true
            ;;
          nj)
            nj=true
            ;;
          *)
            echo "Invalid state '$1' for --import. Valid states: pa, nj"
            exit 1
            ;;
        esac
        shift
      done
      ;;
    --download)
      download_mode=true
      shift
      # Parse state arguments
      while [[ $# -gt 0 ]] && [[ $1 != --* ]]; do
        case $1 in
          pa)
            pa=true
            ;;
          nj)
            nj=true
            ;;
          *)
            echo "Invalid state '$1' for --download. Valid states: pa, nj"
            exit 1
            ;;
        esac
        shift
      done
      ;;
    --reset)
      reset_mode=true
      reset=true
      shift
      # Parse state arguments
      while [[ $# -gt 0 ]] && [[ $1 != --* ]]; do
        case $1 in
          pa)
            pa=true
            ;;
          nj)
            nj=true
            ;;
          *)
            echo "Invalid state '$1' for --reset. Valid states: pa, nj"
            exit 1
            ;;
        esac
        shift
      done
      ;;
    --no-geometry)
      geometry=false
      shift
      ;;
    --dump)
      pg_dump -O -p "${port}" "${db}" > "data/crash_$(date +%F_%I-%M).dump"
      exit 0
      ;;
    --process-nj)
      process_nj=true
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
if test ${import_mode} = false && test ${download_mode} = false && test ${reset_mode} = false && test ${process_nj} = false ; then
  echo "You must choose at least one action. Quitting."
  echo "${usage}"
  exit
fi

# For import, download, and reset mode, pick at least one state
if test ${import_mode} = true && test ${pa} = false && test ${nj} = false ; then
  echo "You must specify at least one state for --import (pa, nj). Quitting."
  echo "${usage}"
  exit
fi

if test ${download_mode} = true && test ${pa} = false && test ${nj} = false ; then
  echo "You must specify at least one state for --download (pa, nj). Quitting."
  echo "${usage}"
  exit
fi

if test ${reset_mode} = true && test ${pa} = false && test ${nj} = false ; then
  echo "You must specify at least one state for --reset (pa, nj). Quitting."
  echo "${usage}"
  exit
fi

# Check that required year env vars (by state) are set.
if test ${pa} = true; then
    # Check that start/end year env vars are set.
    if [[ -z "${pa_start_year}" ]]; then
      echo "Please include a value for 'pa_start_year' in the .env file."
      exit 1
    fi
    if [[ -z "${pa_end_year}" ]]; then
      echo "Please include a value for 'pa_end_year' in the .env file."
      exit 1
    fi

    # Check that they are valid years.
    if (( pa_start_year < 2005 || pa_end_year < 2005 )); then
      echo "Invalid PA year. Data only available from 2005 onwards. Quitting."
      echo "${usage}"
      exit 1
    fi
fi

if test ${nj} = true; then
    # Check that start/end year env vars are set.
    if [[ -z "${nj_start_year}" ]]; then
      echo "Please include a value for 'nj_start_year' in the .env file."
      exit 1
    fi
    if [[ -z "${nj_end_year}" ]]; then
      echo "Please include a value for 'nj_end_year' in the .env file."
      exit 1
    fi

    # Check that they are valid years.
    if (( nj_start_year < 2001 || nj_end_year < 2001 )); then
      echo "Invalid NJ year. Data only available from 2004 onwards. Quitting."
      echo "${usage}"
      exit 1;
    fi
fi

# Handle download actions first
if test ${pa} = true && test ${download_mode} = true; then
  echo "Downloading PA crash data..."
  base_url="https://gis.penndot.pa.gov/gishub/crashZip/District/District-06"

  mkdir -p data/pa

  for year in $(seq ${pa_start_year} ${pa_end_year}); do
    curl "${base_url}/D06_${year}.zip" \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
      -o "data/pa/D06_${year}.zip" \
      -w '%{filename_effective} downloaded\n' \
      --progress-bar
  
    # Extract the ZIP file to the processing directory
    if [ -f "data/pa/D06_${year}.zip" ]; then
      unzip -o "data/pa/D06_${year}.zip" -d "data/pa"
    else
      echo "Warning: Failed to download D06_${year}.zip"
    fi
  done
fi

if test ${nj} = true && test ${download_mode} = true; then
  echo "Downloading NJ crash data..."

  nj_counties=("Burlington" "Camden" "Mercer" "Gloucester")
  tables=("Accidents" "Drivers" "Occupants" "Pedestrians" "Vehicles")

  base_url="https://dot.nj.gov/transportation/refdata/accident"

  mkdir -p data/nj

  for year in $(seq ${nj_start_year} ${nj_end_year}); do
    for county in ${nj_counties[@]}; do
      for table in ${tables[@]}; do
        curl "${base_url}/${year}/${county}${year}${table}.zip" \
          -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
           -o "data/nj/${county}${year}${table}.zip" \
           -w '%{filename_effective} downloaded \n' \
           --progress-bar
      done
    done
  done

  echo "Pre-processing NJ data files..."
  ./src/utils/nj_pre_process_files.sh
fi

# If only downloading, exit here.
if test ${pa} = false && test ${nj} = false && test ${process_nj} = false ; then
  exit
fi

if test ${process_nj} = true; then
  ./src/utils/nj_pre_process_files.sh
fi

## Create custom domains.
psql -q -p "${port}" -d "${db}" < src/domains.sql

if [[ $pa = true ]]; then
  # Copy data files in data/ to location accessible by server, for easier use in COPY, which
  # requires absolute paths/certain permissions.
  mkdir -p "${user_data_dir}/pa"
  cp -r data/pa/*.csv "${user_data_dir}/pa" 2>/dev/null || true

  if [[ $reset = true ]]; then
    read -p "Are you sure want to reset the PA database? (Press y to reset it, any other key to abort.) " -n 1 -r
    echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        psql -p "${port}" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';"
        psql -qb -p "${port}" -d "${db}" -f src/pa/drop.sql
      else
        echo 'Aborted PA reset; continuing with import.'
      fi
  fi

  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -v pa_start_year="${pa_start_year}" -v pa_end_year="${pa_end_year}" -f src/init_vars.sql -f src/pa/init_vars.sql -f src/pa.sql
  
  # pa geometry (if not disabled)
  if [[ $geometry = true ]]; then
    echo "Generating geometry columns for PA crash tables..."
    psql -qb -p "${port}" -d "${db}" -c "SET myvars.pa_start_year = '${pa_start_year}'; SET myvars.pa_end_year = '${pa_end_year}';" -f src/pa/generate_geometry.sql
  fi
fi

if [[ $nj = true ]]; then
  # Copy data files in data/ to location accessible by server, for easier use in COPY, which
  # requires absolute paths/certain permissions.
  mkdir -p "${user_data_dir}/nj"
  cp -r data/nj/*.txt "${user_data_dir}/nj/" 2>/dev/null || true

  if [[ $reset = true ]]; then
    read -p "Are you sure want to reset the NJ database? (Press y to reset it, any other key to abort.) " -n 1 -r
    echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        psql -qb -p "${port}" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';"
        psql -qb -p "${port}" -d "${db}" -f src/nj/drop.sql
      else
        echo 'Aborted NJ reset; continuing with import.'
      fi
  fi

  psql -qb -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" -v nj_start_year="${nj_start_year}" -v nj_end_year="${nj_end_year}" -f src/init_vars.sql -f src/nj/init_vars.sql -f src/nj.sql
  
  # nj geometry (if not disabled)
  if [[ $geometry = true ]]; then
    # Check if NJ roads table exists, download and import if needed
    if ! psql -p "${port}" -d "${db}" -tAc "SELECT EXISTS(SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='nj_roads');" | grep -q 't'; then
      echo "NJ road network not found. Downloading and importing roads for geometry generation..."
      
      # Create roads dir
      mkdir -p data/nj/roads
      
      # Download the shapefile if not there
      if [ ! -f "data/nj/roads/NJ_Roads_shp.zip" ]; then
        echo "Downloading NJDOT road network shapefile..."
        curl "https://www.nj.gov/transportation/refdata/gis/zip/NJ_Roads_shp.zip" \
          -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
          -o "data/nj/roads/NJ_Roads_shp.zip" \
          -w '%{filename_effective} downloaded \n' \
          --progress-bar
      fi
      
      # Extract
      if [ ! -d "data/nj/roads/NJ_Roads_shp" ]; then
        echo "Extracting NJ roads shapefile..."
        unzip -o data/nj/roads/NJ_Roads_shp.zip -d data/nj/roads
      fi
      
      # Import roads
      echo "Importing road network into database (this may take a few minutes)..."
      shp2pgsql -I -s 3424 -W UTF-8 "data/nj/roads/NJ_Roads_shp/NJ_Roads.shp" nj_roads | psql -q -p "${port}" -d "${db}"
      
      if [ $? -eq 0 ]; then
        echo "Road network import complete."
      else
        echo "Road network import failed. Skipping geometry generation."
        exit 1
      fi
    fi
    
    echo "Generating geometry columns for NJ crash tables..."
    psql -qb -p "${port}" -d "${db}" -c "SET session.nj_start_year = '${nj_start_year}'; SET session.nj_end_year = '${nj_end_year}';" -f src/nj/generate_geometry.sql
  fi
fi
