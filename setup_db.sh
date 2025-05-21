#! /usr/bin/env bash

# Bring in environment variables.
. .env

# `port` is a required env var; exit it not set.
if [[ -z "${port}" ]]; then
  echo "Expected environment variable 'port' not found or doesn't have a value; please set it in a .env file." >&2
  exit
fi

# Use db (name) from .env or a default value.
if ! test -v db; then
  db="crash"
fi

# Use user_data_dir from .env or a default value.
if ! test -v user_data_dir; then
  user_data_dir="/tmp/crash-data"
fi

# Use postgres_data_dir from .env or a default value.
if ! test -v postgres_data_dir; then
  postgres_data_dir="/var/lib/postgresql"
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

# Copy data files in data/ to location accessible by server, for easier use in COPY, which
# requires absolute paths/certain permissions.
mkdir -p "${user_data_dir}"
cp -r data/* "${user_data_dir}"

# Run the sql.
psql -p "${port}" -d "${db}" -v user_data_dir="${user_data_dir}" -v postgres_data_dir="${postgres_data_dir}" < src/main.sql 
