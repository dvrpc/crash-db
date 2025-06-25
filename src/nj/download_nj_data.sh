#! /usr/bin/env bash
# first_year=2002
# last_year=2022
nj_counties=("Burlington" "Camden" "Mercer" "Gloucester")
tables=("Accidents" "Drivers" "Occupants" "Pedestrians" "Vehicles")

base_url="https://dot.nj.gov/transportation/refdata/accident"

for year in $(seq ${first_year} ${last_year}); do
  for county in ${nj_counties[@]}; do
    for table in ${tables[@]}; do
      curl "${base_url}/${year}/${county}${year}${table}.zip" \
        -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
         -o "data/nj/${county}${year}${table}.zip"
    done
  done
done

