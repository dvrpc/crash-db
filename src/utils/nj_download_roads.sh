#!/usr/bin/env bash

# Download and import NJDOT road network shapefile

# Load environment variables from .env file
if [ -f "../../.env" ]; then
  set -a
  source ../../.env
  set +a
fi

usage="
Download and import NJ DOT road network shapefile.

Usage:
$(basename $0) [--import]

--import: import the shapefile into the database after download
--help: Show this help message

Downloads and extracts NJ_Roads_shp.zip to ../../data/nj/roads/
If --import is specified, also imports the data into the database.
"

import_data=false

# Parse and handle command line options.
while [[ $# -gt 0 ]]; do
  case $1 in
    --import)
      import_data=true
      shift
      ;;
    --help|-u)
      echo "${usage}"
      exit
      ;;
    *)
      echo "Invalid option $1. Use --help for usage."
      exit 1
      ;;    
  esac
done

# Create road data directory if it doesn't exist
mkdir -p ../../data/nj/roads

echo "Downloading NJDOT road network shapefile..."

# Download the shapefile
curl "https://www.nj.gov/transportation/refdata/gis/zip/NJ_Roads_shp.zip" \
  -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36' \
  -o "../../data/nj/roads/NJ_Roads_shp.zip"

# Check if download was successful
if [ $? -eq 0 ]; then
  echo "Download successful. Extracting..."
  cd ../../data/nj/roads
  unzip -o NJ_Roads_shp.zip
  echo "NJDOT road network shapefile ready."
  cd ../../..
else
  echo "Download failed. Please check your connection and try again."
  exit 1
fi

# Import data if requested
if [ "$import_data" = true ]; then
  echo "Importing road network into database..."
  
  # Check required environment variables
  if [[ -z "${port}" ]]; then
    echo "Error: 'port' environment variable not set. Check your .env file."
    exit 1
  fi
  
  if [[ -z "${db}" ]]; then
    db="crash"
  fi
  
  if [[ -z "${user_data_dir}" ]]; then
    user_data_dir="/tmp/crash-data"
  fi
  
  # Copy shapefile to user_data_dir
  mkdir -p "${user_data_dir}/nj/roads"
  cp -r data/nj/roads/* "${user_data_dir}/nj/roads/"
  
  # Check if table exists and handle accordingly
  table_exists=$(psql -p "${port}" -d "${db}" -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name='nj_roads');")
  
  if [ "$table_exists" = "t" ]; then
    echo "Table nj_roads already exists. Use --roads --reset to recreate it."
  else
    # Import using shp2pgsql
    echo "Running shp2pgsql import (this may take a few minutes)..."
    shp2pgsql -I -s 3424 -W UTF-8 "${user_data_dir}/nj/roads/NJ_Roads_shp/NJ_Roads.shp" nj_roads | psql -q -p "${port}" -d "${db}"
    
    if [ $? -eq 0 ]; then      
      # Show statistics
      echo "Import complete. Road network statistics:"
      psql -p "${port}" -d "${db}" -c "SELECT COUNT(*) as total_roads, ST_GeometryType(geom) as geometry_type FROM nj_roads GROUP BY ST_GeometryType(geom);"
    else
      echo "Import failed. Check database connection and permissions."
      exit 1
    fi
  fi
fi