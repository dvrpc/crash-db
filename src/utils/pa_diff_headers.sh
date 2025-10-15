#! /usr/bin/env bash

usage="
Check that the headers in the PA data files are the same across each table/year.

Usage:
$(basename $0) <year1> <year2>

NOTE: Ensure that the data filenames are in format expected (TABLENAME_GEOGRAPHY_YEAR.csv) e.g. FLAG_D06_2023.csv

"

if [[ "${1}" = '-u' || "${1}" = 'u' ]]; then
  echo "${usage}"
  exit 0
fi

tables=('CRASH' 'COMMVEH' 'CYCLE' 'FLAGS' 'PERSON' 'ROADWAY' 'TRAILVEH' 'VEHICLE')


# Exit if we don't have requirement number of arguments.
num_args_required=2

if [[ ${#} < "${num_args_required}" ]]; then
  echo -e "${num_args_required} arguments required; $# received."
  echo "${usage}"
  exit 1
fi

# Give command line arguments variable names.
year1=$1
year2=$2

error=0

# Check the tables between the years.
for table in "${tables[@]}"; do
  first_file="data/pa/${table}_D06_${year1}.csv"
  next_file="data/pa/${table}_D06_${year2}.csv"

  if ! test -e ${first_file}; then
    echo "Error: Cannot find ${first_file}."
    exit
  fi

  if ! test -e ${next_file}; then
    echo "Error: Cannot find ${next_file}."
    exit
  fi

  echo "${first_file} vs ${next_file}"

  difft --color always --exit-code <(head -n1 ${first_file}) <(head -n1 ${next_file})

  # Check result and set error.
  if test $? != 0; then
    error=1
  fi
done

# Print explicit success message if we've made it all the way to here - script
# would have exited early if error.
if [[ "${error}" != 1 ]]; then
  echo "Success - no differences found."
fi
