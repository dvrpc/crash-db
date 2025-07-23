# Crash Database

The database is constructed via a number of shell and sql scripts. The main entry point is setup_db.sh. If it is not already executable, make it so with `chmod 755 setup_db.sh` and then invoke with `./setup_db.sh -u` to show usage details.

The script assumes that data files (CSVs) are in data/ relative to the project directory, which are then copied to appropriate folders (configurable via environment variables if necessary) to ease access by Postgres's <a href="https://www.postgresql.org/docs/17/sql-copy.html">COPY</a>.

The Postgres user running this script must have been granted two roles: `pg_read_server_files` and `pg_write_server_files`. As a superuser, run `grant pg_read_server_files, pg_write_server_files to <user>`.

A `port` environment variable is required, and others can be used but are optional. Create a .env file in the project directory to set them:

```sh
port=5437
# If you want something other than default of "crash":
db="crash2"
# If you want something other than default of /tmp/crash-data:
# NOTE: the system user you run the script/create the db as needs to read/write from this directory.
user_data_dir="/tmp/somewhere"
# If you want something other than default of /var/lib/postgresql:
# NOTE: the postgres system user needs to be able to read/write from this directory.
postgres_data_dir="/var/lib/postgresql/data" 
```

## Utility Scripts

Utility scripts that can be run independently are in src/utils. Make them executable and run with the `-u` option to see usage.

## TODO:

For either the pa or the dvrpc schema, add in "shape" for better geometry field, using this or something close to it (from Sean Lawrence):

```sql
select 
  latitude, 
  longitude,
  ST_SetSRID(ST_Point((
        CAST(SUBSTRING(longitude FROM 1 FOR POSITION(' ' IN longitude) - 1) AS NUMERIC) + 
        CAST(SUBSTRING(longitude FROM POSITION(' ' IN longitude) + 1 FOR POSITION(':' IN longitude) - POSITION(' ' IN longitude) - 1) AS NUMERIC) / 60 + 
        CAST(SUBSTRING(longitude FROM POSITION(':' IN longitude) + 1) AS NUMERIC) / 3600) * -1,
        (CAST(SUBSTRING(latitude FROM 1 FOR POSITION(' ' IN latitude) - 1) AS NUMERIC) + 
        CAST(SUBSTRING(latitude FROM POSITION(' ' IN latitude) + 1 FOR POSITION(':' IN latitude) - POSITION(' ' IN latitude) - 1) AS NUMERIC) / 60 + 
        CAST(SUBSTRING(latitude FROM POSITION(':' IN latitude) + 1) AS NUMERIC) / 3600)
    ),4326) as shape
from 
  crash -- will need schema specified
```

## Data

### Obtaining and Pre-processing

As there are only a handful of files for PA, these can be downloaded manually and placed in data/pa/district/. No pre-processing prior to sql scripts called by Postgres is done on these files.

For NJ, one shell script (src/utils/nj_download_data.sh) downloads the compressed (.zip) files (to data/nj) and another (src/utils/nj_pre_process_files.sh) extracts and pre-processes them so they can be properly imported into Postgres (see comments in that latter script for additional details).

### PennDOT

Crash data:
  - [2024 Crash Database Primer](https://gis.penndot.gov/gishub/crashZip/OPEN%20DATA%20PORTAL%20Database%20Primer%2010-16.pdf)
  - [2024 data dictionary](https://gis.penndot.pa.gov/gishub/crashZip/Crash_Data_Dictionary_2025.pdf)
  - [2024 data download](https://experience.arcgis.com/experience/51809b06e7b140208a4ed6fbad964990)

#### 2024-version data issues and questions

There are a number of discrepancies between the data dictionary and the CSVs. Those related to
field order or missing fields are noted in src/pa/create_data_tables.sql, in a comment above each table. Those about values can be found in src/pa/alter_temp_domains.sql (which identifies the data issues) and src/pa/clean_data.sql (which cleans it). Further questions are below.

Lookup tables:
  - Some fields have values that aren't in their corresponding lookup tables; where obvious, unambiguous values could be added they were, others were were changed to null. See clean_data.sql and lookup_tables.sql.
  - Some lookup tables were added, taken from explicit values listed in the data dictionary. See lookup_tables.sql.
  - hazmat_rel_1 - hazmat_rel_4 in the commveh table: in the data dictionary, it lists "1=Y, 0=N" as the possible values, but then there is also a lookup table for it that contains "1 – No Release, 2 – Release occurred, 9 – Unknown". The latter is what is actually in the CSV files. This was converted to a boolean field.
  - Some of the values between the pdf and the spreadsheet differ. This seems to be either in spelling, e.g. using "Twp" (pdf) or "Township" (spreadsheet), or zero-padding.

Primary keys:
  - "person" table: is crn/unit_num supposed to be primary key? Duplicate when attempted.
  - "trailveh" table: data dictionary says "The CRN, UNIT_NUM and define the unit that corresponds to the vehicle record". Assume "trl_seq_num" is the missing field here?

Misc:
  - The crash table's "urban_rural" field lists (in comments only, not as separate lookup table) possible values 1=rural, 2=urbanized, 3=urban, but only values in field for all 2023 counties are 1 and 2. So should it be 1=rural, 2=urban? What is "urbanized"?
  - The commveh table's "axle_cnt" doesn't have a lookup table, but seems to use 99 for unknown. Converted to null. But what about others that are very high? What's the highest number of axles a vehicle and trailers could have?
  - The crash table's "lane_closed" field contains no data for years 2008-2024. I have not checked other fields but probably worthwhile to do so. I only happened across this by chance as the previous version of the data had bad values for this field (supposed to by Y/N but contained 0,1,2,9,U).
  - In 2005-2007, lane_closed (boolean) contained '2'. Converted to null.

### NJDOT

Main site: <https://dot.nj.gov/transportation/refdata/accident/>
Data: <https://dot.nj.gov/transportation/refdata/accident/rawdata01-current.shtm>
Data dictionaries: <https://dot.nj.gov/transportation/refdata/accident/masterfile.shtm>
Crash report manual found at <https://dot.nj.gov/transportation/refdata/accident/publications.shtm>.

Lookup tables:
  <https://dot.nj.gov/transportation/refdata/accident/codes.shtm>
  <https://dot.nj.gov/transportation/refdata/accident/crash_detail_summary.shtm>
  <https://dot.nj.gov/transportation/refdata/accident/forms.shtm>

  2017:
    <https://dot.nj.gov/transportation/refdata/accident/pdf/NJTR-1_Overlays.pdf>
  2006-2016:
    <https://dot.nj.gov/transportation/refdata/accident/pdf/NJTR-1.pdf>
  2001-2005:
    <https://dot.nj.gov/transportation/refdata/accident/pdf/NJTR-1_2001.pdf>

#### Data issues

  - Backslashes found in various files. These break Postgres's COPY. They are escaped (with another backslash) via src/utils/nj_pre_process_files.sh. 
  - Literal carriage returns (break to next line) were found in various files. These break the line specification. They are replaced with a space via src/utils/nj_pre_process_files.sh.
  - police_station field in crash table seems to often just be the same as dept_case_number, other times it's text
  - In 2021 and 2022, in the Drivers and Pedestrians tables, DOB is an empty field with a length of zero, while the specification indicates it should have a length of ten. This makes all of the subsequent from/to/length values incorrect in the corresponding table layout pdf. These fields were removed from our version of the table for these years. All prior years (2001-2020) do have a length of 10 for this field. Is there a problem with the 2021 and 2022 tables? Has the specification changed started in 2021? Will this field be included going forward?
  - See src/nj/create_data_tables.sql for questions about fields that appear to be lookup tables but whose values cannot be located and src/nj/lookup_tables.sql for questions about exact order/values in tables. Each is highlighted by a preceding "TODO" item in a comment.
  - literal line feed character in line that was removed manually/characters adjusted within field where the lf was. Not yet sure how to handle programmatically.
    - 2020 Burlington Drivers table, line 59-60
    - 2020 Camden Drivers table, line 4019-20, line 17425-6,
