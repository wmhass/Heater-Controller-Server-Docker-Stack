#!/bin/bash
set -e

# CREATE USER mqtt_access_control;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE apps_open_api;
    GRANT ALL PRIVILEGES ON DATABASE apps_open_api TO postgres;
EOSQL
