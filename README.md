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
- **pgtap**: For testing purposes (not required)

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
pa_start_year=2024  # earliest year that data is available for is 2005
pa_end_year=2024
nj_start_year=2022  # earliest year that data is available for is 2001
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

**Note**: NJ crash data requires the road network to be imported first for geometry generation. If you run `--nj` without `--roads`, a warning will be displayed.

### Important Considerations
- **Data Years**: Ensure the year ranges in your `.env` file are within the available data bounds:
  - PA: 2005 and later
  - NJ: 2006 and later
- **Spatial Data**: NJ crash data requires the road network to generate geometries on import

## Data

### PennDOT

  - 2024 Crash Database Primer: <https://gis.penndot.gov/gishub/crashZip/OPEN%20DATA%20PORTAL%20Database%20Primer%2010-16.pdf>
  - 2024 data dictionary: <https://gis.penndot.pa.gov/gishub/crashZip/Crash_Data_Dictionary_2025.pdf>
  - 2024 data download: <https://experience.arcgis.com/experience/51809b06e7b140208a4ed6fbad964990>

#### 2024-version data issues and questions

There are a number of discrepancies between the data dictionary and the CSVs. Those related to field order or missing fields are noted in src/pa/create_data_tables.sql, in a comment above each table. Those about values can be found in src/pa/alter_temp_domains.sql (which identifies the data issues) and src/pa/clean_data.sql (which cleans it). Further questions are below.

Lookup tables:
  - Some fields have values that aren't in their corresponding lookup tables; where obvious, unambiguous values could be added they were, others were were changed to null. See clean_data.sql and lookup_tables.sql.
  - Some lookup tables were added, taken from explicit values listed in the data dictionary. See lookup_tables.sql.
  - hazmat_rel_1 - hazmat_rel_4 in the commveh table: in the data dictionary, it lists "1=Y, 0=N" as the possible values, but then there is also a lookup table for it that contains "1 – No Release, 2 – Release occurred, 9 – Unknown". The latter is what is actually in the CSV files. This was converted to a boolean field.
  - Some of the values between the pdf and the spreadsheet differ. This seems to be either in spelling, e.g. using "Twp" (pdf) or "Township" (spreadsheet), or zero-padding.

Primary keys:
  - "person" table: is crn/unit_num supposed to be primary key? Duplicate when attempted.
  - "trailveh" table: data dictionary says "The CRN, UNIT_NUM and define the unit that corresponds to the vehicle record". Assume "trl_seq_num" is the missing field here?

Misc:
  - The crash table's "urban_rural" field lists (in comments only, not as separate lookup table) possible values 1=rural, 2=urbanized, 3=urban, but only values across all years are 1 and 2. So should it be 1=rural, 2=urban? What is "urbanized"?
  - The commveh table's "axle_cnt" doesn't have a lookup table, but seems to use 99 for unknown. Converted to null. But what about others that are very high? What's the highest number of axles a vehicle and trailers could have?
  - The crash table's "lane_closed" field contains no data for years 2008-2024. I have not checked other fields but probably worthwhile to do so. I only happened across this by chance as the previous version of the data had bad values for this field (supposed to by Y/N but contained 0,1,2,9,U).
  - In 2005-2007, lane_closed (boolean) contained '2'. Converted to null.

### NJDOT

  - Main site: <https://dot.nj.gov/transportation/refdata/accident/>
  - Data: <https://dot.nj.gov/transportation/refdata/accident/rawdata01-current.shtm>
  - Data dictionaries: <https://dot.nj.gov/transportation/refdata/accident/masterfile.shtm>
  - Manuals: <https://dot.nj.gov/transportation/refdata/accident/publications.shtm>.
  - NJTR-1 Forms: <https://dot.nj.gov/transportation/refdata/accident/forms.shtm>

#### Data issues

  - The data for one crash in the 2016 data lacked a value for the "department case number" field, and as that's part of the primary key, the records for it weren't inserted into the various tables.
  - The zip file for Burlington 2009 Drivers is empty, and so that year's data cannot be imported.
  - Backslashes found in various files. These break Postgres's COPY. They are escaped (with another backslash) via src/utils/nj_pre_process_files.sh. 
  - Literal carriage returns (break to next line) were found in various files. These break the line specification. They are replaced with a space via src/utils/nj_pre_process_files.sh.
  - Line feeds (new line, \n) found in the middle of some lines in various files (and sometimes several of them - seems to be in addresses). These break the line specification. They are replaced with a space via src/utils/nj_pre_process_files.sh.
  - police_station field in crash table seems to often just be the same as dept_case_number, other times it's text
  - In 2021 and 2022, in the Drivers and Pedestrians tables, DOB is an empty field with a length of zero, while the specification indicates it should have a length of ten. This makes all of the subsequent from/to/length values incorrect in the corresponding table layout pdf. These fields were removed from our version of the table for these years. All prior years (2001-2020) do have a length of 10 for this field. Is there a problem with the 2021 and 2022 tables? Has the specification changed started in 2021? Will this field be included going forward?
  - See src/nj/create_data_tables.sql for questions about fields that appear to be lookup tables but whose values cannot be located and src/nj/lookup_tables.sql for questions about exact order/values in tables. Each is highlighted by a preceding "TODO" item in a comment.
