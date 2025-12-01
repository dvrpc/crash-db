# macOS -> Linux VM testing

This guide helps macOS users run the crash database setup tool in an Ubuntu VM using Multipass.  The setup script does run natively in macOS so this isn't necessary really.

## Prerequisites

1. Install Multipass:
   ```bash
   brew install multipass
   ```

2. Ensure you have the crash-db repository cloned locally

3. `.env` variables set (see [readme.md](README.md))

    **NOTE**: macOS PostgreSQL installations vary.  Postgres.app data directory is usually something like this `/Users/your_login/Library/Application Support/Postgres/var-17`

## Setup Steps

### 1. Create Ubuntu VM with PostgreSQL 17

```bash
# Create and launch VM with mounted crash-db directory
multipass launch --name crash-db --memory 4G --disk 20G --cpus 2 \
  --mount /path/to/crash-db:/home/ubuntu/crash-db 24.04

# Install prerequisites
multipass exec crash-db -- bash -c "sudo apt-get update && sudo apt-get install -y curl ca-certificates"

# Add PostgreSQL 17 repo
multipass exec crash-db -- bash -c "
  sudo install -d /usr/share/postgresql-common/pgdg && \
  sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc && \
  sudo sh -c 'echo \"deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt noble-pgdg main\" > /etc/apt/sources.list.d/pgdg.list' && \
  sudo apt-get update
"

# Install PostgreSQL 17, PostGIS extension, and PostGIS command-line tools
multipass exec crash-db -- bash -c "sudo apt-get install -y postgresql-17 postgresql-17-postgis-3 postgis unzip"

# Create database user and initial database with PostGIS
multipass exec crash-db -- bash -c "
  cd /home/ubuntu/crash-db && \
  sudo -u postgres psql -c \"CREATE USER ubuntu WITH SUPERUSER\" 2>/dev/null || true && \
  DB_NAME=\$(grep '^db=' .env | cut -d'\"' -f2) && \
  sudo -u postgres psql -c \"CREATE DATABASE \${DB_NAME}\" 2>/dev/null || echo \"Database \${DB_NAME} may already exist\" && \
  sudo -u postgres psql -d \${DB_NAME} -c \"CREATE EXTENSION IF NOT EXISTS postgis\"
"
```

### 2. Configure and Run Setup

```bash
# Shell into the VM
multipass shell crash-db

# Navigate to the mounted directory
cd /home/ubuntu/crash-db

# Verify .env configuration (edit if needed)
cat .env

# Run setup - example: download and import PA data
./setup_db.sh --download pa --import pa
```

## Managing the VM

```bash
# Stop the VM
multipass stop crash-db

# Start the VM
multipass start crash-db

# Delete the VM (when done)
multipass delete crash-db
multipass purge
```

## Notes

- The crash-db directory is mounted and shared between your Mac and the VM
- Any changes to files in crash-db are immediately visible in both environments
- Data downloaded in the VM is stored in the mounted directory and persists on your Mac
- Please check [readme.md](README.md) for further instruction on how to use the crash-db tool.
