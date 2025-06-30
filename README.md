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
Data dictionaries: <https://dot.nj.gov/transportation/refdata/accident/masterfile.shtm>
Data: <https://dot.nj.gov/transportation/refdata/accident/rawdata01-current.shtm>

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


  

  

A shell script at src/utils/download_nj_data.sh will download all tables for our four counties.
