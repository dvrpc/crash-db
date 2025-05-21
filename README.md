# Crash Database

The database is contructed via a number of shell and sql scripts. The main entry point is setup_db.sh.

The Postgres user running this script must have been granted two roles: `pg_read_server_files` and `pg_write_server_files`. As a superuser, run `grant pg_read_server_files, pg_write_server_files to <user>`.

## TODO:

- [ ] finish cleaning data for pa 2023
  - [ ] verify the order/inclusion of all the fields between the data dictionary/create tables sql scripts and the actual CSVs - have found several discrepencies (noted in sql scripts)
- [ ] optimize queries when doing the data cleaning - turning off any kind of indexing, etc.
  - See e.g. <https://www.cybertec-postgresql.com/en/postgresql-bulk-loading-huge-amounts-of-data/> 
- [ ] add help flag to show usage to setup_db.sh
- [ ] figure out how to use variable in `copy` command, to pass data directory ("/tmp/crash-data") (hardcoding for now)
- [ ] review this after complete: <https://www.postgresql.org/docs/current/populate.html>

## Environment Variables

Create a .env file. `port` is required but others are optional. 
```sh
port=5437
db="crash2"  # If you want something other than "crash", which is the default.
```

## Usage

The database is created and populated via the setup.sh bash script. If it is not already executable, make it so with `chmod 755 setup_db.sh` and then invoke with `./setup_db.sh`. You can optionally drop and recreate the existing database with the `-r` flag: `./setup_db.sh -r`, which will also terminate any existing connections in order to do so.

The script copies the files in /data to /tmp, to ease access by Postgresql's <a href="https://www.postgresql.org/docs/17/sql-copy.html">COPY</a>, which is used to import the data into temporary tables before it is cleaned.

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
