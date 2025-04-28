# Crash Database

The database is contructed via a number of shell and sql scripts. The main entry point is setup_db.sh.

## TODO:

- [ ] finish cleaning data for pa 2023
- [ ] optimize queries when doing the data cleaning - turning off any kind of indexing, etc.
  - See e.g. <https://www.cybertec-postgresql.com/en/postgresql-bulk-loading-huge-amounts-of-data/> 
- [ ] add help flag to show usage to setup_db.sh
- [ ] figure out how to use variable in `copy` command, to pass data directory ("/tmp/crash-data") (hardcoding for now)
- [ ] review this after complete: <https://www.postgresql.org/docs/current/populate.html>

## Environment Variables

Create a .env file. `port` is required but all else are optional. 
```sh
port=5437
db="crash2"  # If you want something other than "crash", which is the default.
```

## Usage

The database is created and populated via the setup.sh bash script. If it is not already executable, make it so with `chmod 755 setup_db.sh` and then invoke with `./setup_db.sh`. You can optionally drop and recreate the existing database with the `-r` flag: `./setup_db.sh -r`.

The script copies the files in /data to /tmp, to ease access by Postgresql's <a href="https://www.postgresql.org/docs/17/sql-copy.html">COPY</a>, which is used to import the data into temporary tables before it is cleaned.

## Data

### PennDOT

Crash data:
  - [Crash Database Primer](https://gis.penndot.gov/gishub/crashZip/OPEN%20DATA%20PORTAL%20Database%20Primer%2010-16.pdf)
  - [Data dictionary](https://gis.penndot.gov/gishub/crashZip/Open%20Data%20Portal%20Data%20Dictionary%20(07-24).pdf)
  - [Download data by county or entire state](https://pennshare.maps.arcgis.com/apps/webappviewer/index.html?id=8fdbf046e36e41649bbfd9d7dd7c7e7e)

#### Questions/Data Issues

If there's a value of "2" where the data dictionary states there's only supposed to 0=no and 1=yes, is this unknown? (e.g. "lane_closed" in crash tables, probably others.) I'm changing them to nulls. Same thing with "U" where the data dictionary states possibilities of "Y" or "N". 

In the 2023 Vehicle table CSVs, there's no hazmat_ind field, which is listed in the data dictionary for that table. I have commented it out in the `create table` query.

In the 2023 Vehicle table CSVs, the field "TOW_IND" is not listed in the data dictionary. I've added it as a boolean.
