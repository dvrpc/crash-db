#! /usr/bin/env bash

usage="
Check that the headers in the data files are the same across each table/state/year.

Usage:
$(basename $0) <state_abbr> <year1> <year2>

NOTE: Ensure that the data filenames are in format expected (TABLENAME_GEOGRAPHY_YEAR.csv) e.g. FLAG_D06_2023.csv

"

if [[ "${1}" = '-u' || "${1}" = 'u' ]]; then
  echo "${usage}"
  exit 0
fi

tables=('CRASH' 'COMMVEH' 'CYCLE' 'FLAG' 'PERSON' 'ROADWAY' 'TRAILVEH' 'VEHICLE')


# Exit if we don't have requirement number of arguments.
num_args_required=3

if [[ ${#} < "${num_args_required}" ]]; then
  echo -e "${num_args_required} arguments required; $# received."
  echo "${usage}"
  exit 1
fi

# Give command line arguments variable names, making state lowercase.
state="${1,,}"
year=$2
year2=$3

error=0

if [ "${state}" = 'pa' ]; then
  # Check the tables between the years.
  for table in "${tables[@]}"; do
    first_file="data/${state}/${table}_D06_${year}.csv"
    next_file="data/${state}/${table}_D06_${year2}.csv"
    echo "${first_file} vs ${next_file}"
    difft --color always --exit-code <(head -n1 ${first_file}) <(head -n1 ${next_file})

    # Check result and set error.
    if test $? != 0; then
      error=1
    fi
  done

elif [ "${state}" == 'nj' ]; then
  echo "Not yet set up for New Jersey."
  exit 1
  # This outdated check on data from PA - before it was available for DVPRC region - may
  # be useful in NJ. Haven't yet explored how data is organized.
  # # Check tables in the same year.
  # for table in "${tables[@]}"; do
  #   first_file="data/${state}/${year}/${table}_${pa_counties[0]}_${year}.csv"
  #   for i in {1..4}; do
  #     # Compare 1st county's CSV header with 2nd, then 1st with 3rd, etc.
  #     next_file="data/${state}/${year}/${table}_${pa_counties[${i}]}_${year}.csv"
  #     echo "${first_file} vs ${next_file}"
  #     difft --color always --exit-code  <(head -n1 ${first_file}) <(head -n1 ${next_file})

  #     # Check result and set error.
  #     if test $? != 0; then
  #       error=1
  #     fi
  #   done     
  # done
else
  echo "Invalid state abbreviation - use 'PA'/'pa' or 'NJ'/'nj'."
  exit 1
fi

# Print explicit success message if we've made it all the way to here - script
# would have exited early if error.
if [[ "${error}" != 1 ]]; then
  echo "Success - no differences found."
fi
