# Crash Database

The database is contructed via a number of shell and sql scripts. The main entry point is setup_db.sh.

The Postgres user running this script must have been granted two roles: `pg_read_server_files` and `pg_write_server_files`. As a superuser, run `grant pg_read_server_files, pg_write_server_files to <user>`.

## TODO:

- [ ] finish cleaning data for pa 2023
  - [ ] verify the order/inclusion of all the fields between the data dictionary/create tables sql scripts and the actual CSVs - have found several discrepencies (noted in sql scripts)
- [ ] optimize queries when doing the data cleaning - turning off any kind of indexing, etc.
  - See e.g. <https://www.cybertec-postgresql.com/en/postgresql-bulk-loading-huge-amounts-of-data/> 
- [ ] add help flag to show usage to setup_db.sh
- [ ] review this after complete: <https://www.postgresql.org/docs/current/populate.html>

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

## Environment Variables

Create a .env file. `port` is required but others should be optional, depending on your OS.
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

## Usage

The database is created and populated via the setup.sh bash script. If it is not already executable, make it so with `chmod 755 setup_db.sh` and then invoke with `./setup_db.sh`. You can optionally drop and recreate the existing database with the `-r` flag: `./setup_db.sh -r`, which will also terminate any existing connections in order to do so.

The script assumes that data files (CSVs) are in data/ relative to the project directory, which are then copied to appropriate folders (configurable via environment variables if necessary) to ease access by Postgresql's <a href="https://www.postgresql.org/docs/17/sql-copy.html">COPY</a>.

### Utility Scripts

The way these are invoked may change. At present, there's one script, at src/diff_headers.sh, which checks that all the headers in the data files are the same across each table/state/year. Run it with `./src/diff_headers.sh <state> <year>` from the project root.

## Data

### PennDOT

Crash data:
  - [Crash Database Primer](https://gis.penndot.gov/gishub/crashZip/OPEN%20DATA%20PORTAL%20Database%20Primer%2010-16.pdf)
  - [Data dictionary](https://gis.penndot.gov/gishub/crashZip/Open%20Data%20Portal%20Data%20Dictionary%20(07-24).pdf)
  - [Download data by county or entire state](https://pennshare.maps.arcgis.com/apps/webappviewer/index.html?id=8fdbf046e36e41649bbfd9d7dd7c7e7e)

#### Questions/Data Issues - 2023

There are a number of discrepencies between the data dictionary and the CSVs. Details are noted in src/pa/2023/create_data_tables.sql, in a comment above each table.

If there's a value of "2" where the data dictionary states there's only supposed to 0=no and 1=yes, is this unknown? (e.g. "lane_closed" in crash tables, probably others.) I'm changing them to nulls. Same thing with "U" where the data dictionary states possibilities of "Y" or "N". 

There are a number of "R" values for the "transported" field in the person CSVs - enough to suggest that this was intentional. However, field is supposed to be y/n. What would R mean? Converting to null for now.
