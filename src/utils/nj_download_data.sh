#! /usr/bin/env bash

usage="
Download NJ data by year (starting from 2001).

Usage:
$(basename $0) start_year [end_year]

Use 'start_year' without an 'end_year' to download data for a single year.
"
# Parse and handle command line options.
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

nj_counties=("Burlington" "Camden" "Mercer" "Gloucester")
tables=("Accidents" "Drivers" "Occupants" "Pedestrians" "Vehicles")

base_url="https://dot.nj.gov/transportation/refdata/accident"

if [ -z $1 ]; then
  1>&2 echo "Start year not provided. Quitting."
  echo "${usage}"
  exit 1
fi

first_year=$1

if [ -z $2 ]; then
  last_year=$1
else
  last_year=$2
fi

if (( first_year < 2001 || last_year < 2001 )); then
  echo "Invalid year. Quitting."
  echo "${usage}"
  exit;
fi

for year in $(seq ${first_year} ${last_year}); do
  for county in ${nj_counties[@]}; do
    for table in ${tables[@]}; do
      curl "${base_url}/${year}/${county}${year}${table}.zip" \
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
         -o "data/nj/${county}${year}${table}.zip"
    done
  done
done

