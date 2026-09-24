# Crash Database

<!--toc:start-->
  - [Introduction](#introduction)
  - [Installation Requirements](#installation-requirements)
    - [System Dependencies](#system-dependencies)
    - [User Permissions](#user-permissions)
  - [Setup Process](#setup-process)
    - [Phase 1: Download Data](#phase-1-download-data)
    - [Phase 2: Import and Process Data](#phase-2-import-and-process-data)
    - [Additional Options](#additional-options)
    - [Important Considerations](#important-considerations)
  - [Data](#data)
    - [PennDOT](#penndot)
      - [2024-version data issues and questions](#2024-version-data-issues-and-questions)
    - [NJDOT](#njdot)
      - [Data issues](#data-issues)
<!--toc:end-->

## Introduction

This project creates a comprehensive PostgreSQL database for vehicle crash data from Pennsylvania (PennDOT) and New Jersey (NJDOT). The tool handles downloading, preprocessing, importing, data validation and cleaning, and spatially enabling the crash data.

The database is constructed via shell and SQL scripts, with the main entry point being `setup_db.sh`. 

## Installation Requirements

Before running the setup scripts, ensure you have the following installed:

### System Dependencies
- **PostgreSQL** 17+: Database server with appropriate permissions
- **postgis**: Spatial data functions for PostgreSQL
- **unzip**: Some Linux installs might need this
- **shp2pgsql**: Command-line tool for importing shapefiles (part of PostGIS)

### User Permissions
The PostgreSQL user running this script must have been granted two roles:
```sql
GRANT pg_read_server_files, pg_write_server_files TO <user>;
```

### Environment Configuration

Create a `.env` file in the project directory with the following variables:

```sh
# NOTE: REQUIRED
port=5437 

# NOTE: REQUIRED
# start and end years for each state
# use the same year for start and end to process a single year's data
pa_start_year=2024  # earliest year that data is available for is 2006
pa_end_year=2024
nj_start_year=2022  # earliest year that data is available for is 2006
nj_end_year=2022

# NOTE: ALL OTHERS OPTIONAL
# If you want something other than default of "crash":
db="crash2"

# If you want something other than default of /tmp/crash-data:
# NOTE: the system user you run the script/create the db as needs to read/write from this directory.
user_data_dir="/tmp/somewhere"

# If you want something other than default of /var/lib/postgresql:
# NOTE: the postgres system user needs to be able to read/write from this directory.
postgres_data_dir="/var/lib/postgresql/data" 
```

## Setup Process

The typical workflow involves two phases: downloading data and importing it into the database.

### Phase 1: Download Data 
First, download the required data files:

```bash
# Download PA crash data (uses pa_start_year and pa_end_year from .env)
./setup_db.sh --download-pa

# Download NJ crash data (uses nj_start_year and nj_end_year from .env)
# (note this does some pre-processing of the files so they can be handled by Postgres) 
./setup_db.sh --download-nj

# Download NJ road network shapefile
./setup_db.sh --download-roads

# Or download everything at once:
./setup_db.sh --download-pa --download-nj --download-roads
```

### Phase 2: Import and Process Data
After downloading, import the data into the database:

```bash
# Import NJ road network (required for NJ crash geometry generation)
./setup_db.sh --roads

# Import crash data for both states
./setup_db.sh --nj --pa
```

### Additional Options
- `--reset`: Reset database (drop and recreate all objects) by state
- `--process-nj`: Pre-process NJ data without first downloading it (when already downloaded)
- `--dump`: Export existing database to a timestamped dump file
- `--usage`: Show detailed usage information

### Important Considerations
- **Data Years**: Ensure the year ranges in your `.env` file are within the available data bounds:
  - PA: 2006 and later
  - NJ: 2006 and later
- **Spatial Data**: NJ crash data requires the road network to be imported first for geometry generation. If you run `--nj` without `--roads`, a warning will be displayed. 

## Data

NOTE: Where lookup tables contain reserved codes/values, they are included in the sql scripts that create them but commented out, and thus not included in the database. If those codes/values are subsequently used in the data tables, they are changed to NULL values.

### PennDOT

  - 2024 Crash Database Primer: <https://gis.penndot.gov/gishub/crashZip/OPEN%20DATA%20PORTAL%20Database%20Primer%2010-16.pdf>
  - Data dictionary (06-26 version): <https://gis.penndot.pa.gov/gishub/crashZip/Crash_Data_Dictionary_2026.pdf>
  - 2024 data download: <https://experience.arcgis.com/experience/51809b06e7b140208a4ed6fbad964990>

#### 2025 re-issue of all years

In June 2026, PennDOT re-published the data for every year (2006-2025; 2005 is no longer available) in a single, new layout, and revised the data itself (e.g. slightly different row counts than earlier downloads). Files downloaded before then are in the old layout and will no longer import; re-download them. The new layout added these fields, which are populated back to 2006 unless noted:

  - crash: vulnerable_road_user_count, vulnerable_road_user_death_count, vulnerable_road_user_ser_inj_count
  - flags: crossing_median_reported, ev (all false in earlier years), hit_bridge_overhead_structure, wrong_way_expressways_only
  - vehicle: vin_eng_fuel_cd (fuel type according to the VIN; the dictionary says it's unavailable before 2018, though a small number of earlier records have it)

Changes made to lookup tables from the 2026 data dictionary (values previously changed to null in clean_data.sql are now kept):
  - seat_position: fourth/other/unknown row codes are 16-24 (previously listed as 21-29, which mislabeled 21-24 and nulled 16-20).
  - restraint_helmet: 21 is rear-facing and 22 front-facing child seat (previously swapped; confirmed by the ages of those persons). Added 13 (Stretcher) and 14 (Wheelchair).
  - veh_or_non_motorist_position: added 00 (Not Applicable (for Peds)).
  - transported_by: added 03 (Law Enforcement).
  - New codes not yet seen in the data: inj_severity/max_severity_level 5 (Died Prior to Crash), weather 11 (Smog or Smoke), veh_or_non_motorist_movement 20-22, avoid_man_cd 8 (Unknown).
  - New vin_eng_fuel_cd lookup table.

#### 2024-version data issues and questions

There are a number of discrepancies between the data dictionary and the CSVs. Those related to field order or missing fields are noted in src/pa/create_data_tables.sql, in a comment above each table. Those about values can be found in src/pa/alter_temp_domains.sql (which identifies the data issues) and src/pa/clean_data.sql (which cleans it). Further questions are below.

Lookup tables:
  - Some fields have values that aren't in their corresponding lookup tables; where obvious, unambiguous values could be added they were, others were were changed to null. See clean_data.sql and lookup_tables.sql.
  - Some lookup tables were added, taken from explicit values listed in the data dictionary. See lookup_tables.sql.
  - hazmat_rel_ind1 - hazmat_rel_ind4 in the commveh table use "1 – No Release, 2 – Release occurred, 9 – Unknown" (earlier data dictionaries also listed "1=Y, 0=N"; the 2026 version is consistent with the data). This was converted to a boolean field.
  - Some of the values between the pdf and the spreadsheet differ. This seems to be either in spelling, e.g. using "Twp" (pdf) or "Township" (spreadsheet), or zero-padding.

Misc:
  - The commveh table's "axle_cnt" uses 0-97 for counts, 98 for Other and 99 for Unknown (per the 2026 data dictionary); 98 and 99 are converted to null. A handful of values are implausibly high (e.g. 62, 94) but within the dictionary's range, so they're kept.
  - The crash table's "lane_closed" field: the data dictionary lists "1=Y, 0=N", but the data uses 0 (not applicable), 1 (partially closed), 2 (fully closed) and 9 (unknown), consistent with ln_close_dir; the lookup table uses the latter. (In pre-2026 downloads this field was empty for 2008-2024; the re-issued data has it for all years.)

### NJDOT

  - Main site: <https://dot.nj.gov/transportation/refdata/accident/>
  - Data: <https://dot.nj.gov/transportation/refdata/accident/rawdata01-current.shtm>
  - Data dictionaries: <https://dot.nj.gov/transportation/refdata/accident/masterfile.shtm>
  - Manuals: <https://dot.nj.gov/transportation/refdata/accident/publications.shtm>.
  - NJTR-1 Forms: <https://dot.nj.gov/transportation/refdata/accident/forms.shtm>

#### Data issues

  - The data for one crash in the 2016 data lacked a value for the "department case number" field, and as that's part of the primary key, the records for it weren't inserted into the various tables.
  - The zip file for Burlington 2009 Drivers is empty, and so that year's data cannot be imported.
  - Two zip files contain extra files in addition to the one they should contain. (Note, however, that the extra files match the ones in their corresponding zip files so they are ok.)
    - Gloucester2014Occupants.zip
    - Camden2019Occupants.zip
  - Backslashes found in various files. These break Postgres's COPY. They are escaped (with another backslash) via src/utils/nj_pre_process_files.sh. 
  - Literal carriage returns (break to next line) were found in various files. These break the line specification. They are replaced with a space via src/utils/nj_pre_process_files.sh.
  - Line feeds (new line, \n) found in the middle of some lines in various files (and sometimes several of them - seems to be in addresses). These break the line specification. They are replaced with a space via src/utils/nj_pre_process_files.sh.
  - police_station field in crash table seems to often just be the same as dept_case_number, other times it's text
  - For 2021-2023, in the Drivers and Pedestrians tables, DOB is an empty field with a length of 0, while the specification states it should have a length of 10. In the latest (2023) version of the table layout, it’s now noted that “Effective in 2021 data no longer displayed, field retained” however the columns in the table have not been updated and so are incorrect starting from this field.
  - See src/nj/create_data_tables.sql for questions about fields that appear to be lookup tables but whose values cannot be located and src/nj/lookup_tables.sql for questions about exact order/values in tables. Each is highlighted by a preceding "TODO" item in a comment.
