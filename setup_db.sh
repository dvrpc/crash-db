#! /usr/bin/env bash

# Bring in environment variables.
. .env

# `port` is a required env var; exit it not set.
if [[ -z "${port}" ]]; then
  echo "Expected environment variable 'port' not found or doesn't have a value; please set it in a .env file." >&2
  exit
fi

# Use db name from from .env or a default value.
if ! test -v db; then
  db="crash"
fi

# Parse and handle command line arguments.
while getopts ":r" opt; do
  case $opt in
    # Reset db if requested.
    r)
      echo "Resetting database"
      # Terminate any connections so the database can be dropped.
      psql -p "${port}" -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname='${db}';"
      # Drop and create.
      dropdb -p "${port}" "${db}"
      createdb -p "${port}" "${db}"
      ;;
  esac
done

# Copy data directory to /tmp for easier use in COPY, which requies absolute paths.
data_dir="/tmp/crash-data/"
mkdir -p "${data_dir}"
cp -r data/* "${data_dir}"

psql -p "${port}" -d "${db}" < src/main.sql # -v data_dir="${data_dir}"
