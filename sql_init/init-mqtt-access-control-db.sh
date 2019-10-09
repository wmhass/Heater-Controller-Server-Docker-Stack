#!/bin/bash
set -e

# CREATE USER mqtt_access_control;
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE mqtt_access_control;
    GRANT ALL PRIVILEGES ON DATABASE mqtt_access_control TO postgres;
EOSQL
