#!/usr/bin/env bash

# Load environment variables from .env file
if [ -f "../../.env" ]; then
  set -a
  source ../../.env
  set +a
fi

usage="
Download PA crash data by year for District 06 (starting from 2005).

Usage:
$(basename $0) [start_year] [end_year]

If no arguments provided, uses pa_start_year and pa_end_year from .env file.
Use 'start_year' without an 'end_year' to download data for a single year.
"

while getopts ":u" opt; do
  case $opt in
    u)
      echo "${usage}"
      exit
      ;;
    \?)
      1>&2 echo "Invalid option -${OPTARG}. Quitting."
      echo "${usage}"
      exit 1
      ;;    
  esac
done

base_url="https://gis.penndot.pa.gov/gishub/crashZip/District/District-06"

if [ -z $1 ]; then
  if [ -z "$pa_start_year" ]; then
    1>&2 echo "Start year not provided and pa_start_year not set in .env. Quitting."
    echo "${usage}"
    exit 1
  fi
  first_year=$pa_start_year
  last_year=${pa_end_year:-$pa_start_year}
else
  first_year=$1
  if [ -z $2 ]; then
    last_year=$1
  else
    last_year=$2
  fi
fi

if (( first_year < 2005 || last_year < 2005 )); then
  echo "Invalid year. Data only available from 2005 onwards. Quitting."
  echo "${usage}"
  exit 1
fi

# Create data directories if they don't exist
mkdir -p ../../data/pa

# Use user_data_dir from .env or default value
if [ -z "${user_data_dir}" ]; then
  user_data_dir="/tmp/crash-data"
fi
mkdir -p "${user_data_dir}/pa"

for year in $(seq ${first_year} ${last_year}); do
  echo "Downloading District-06 data for ${year}..."
  curl "${base_url}/D06_${year}.zip" \
    -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
    -o "../../data/pa/D06_${year}.zip"
  
  # Extract the ZIP file to the processing directory
  if [ -f "../../data/pa/D06_${year}.zip" ]; then
    echo "Extracting D06_${year}.zip to ${user_data_dir}/pa..."
    unzip -o "../../data/pa/D06_${year}.zip" -d "${user_data_dir}/pa"
  else
    echo "Warning: Failed to download D06_${year}.zip"
  fi
done