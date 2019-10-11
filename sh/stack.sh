#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"

# docker pull my-registry:9000/mqtt_access_control_api_service:stable
# docker pull my-registry:9000/apps_open_api_service:stable
# docker pull my-registry:9000/nginx_service:stable
# docker pull my-registry:9000/mqtt_broker_service:stable
# docker pull my-registry:9000/mqtt_client_observer_service:stable
# docker pull my-registry:9000/mqtt_http_api_service:stable

cd $SCRIPT_DIR/../
# Check for parameters
PARAMETERS="$@"

# Development
if [[ " ${PARAMETERS[@]} " =~ " --dev " ]]; then

  # Start Development
  if [[ " ${PARAMETERS[@]} " =~ " --start " ]]; then
    docker-compose -f docker-compose.yml up -d
    docker-compose -f docker-compose.yml ps
  # Stop Development
  elif [[ " ${PARAMETERS[@]} " =~ " --stop " ]]; then
    docker-compose -f docker-compose.yml down
    docker-compose -f docker-compose.yml ps
  # No action
  else
    echo "Nothing to execute. Please run with --start or --stop"
  fi

# Production
elif [[ " ${PARAMETERS[@]} " =~ " --prod " ]]; then

  # Start Production
  if [[ " ${PARAMETERS[@]} " =~ " --start " ]]; then
    docker-compose -f docker-compose.prod.yml up -d
    docker-compose -f docker-compose.prod.yml ps
  # Stop Production
  elif [[ " ${PARAMETERS[@]} " =~ " --stop " ]]; then
    docker-compose -f docker-compose.prod.yml down
    docker-compose -f docker-compose.prod.yml ps
  # No action
  else
    echo "Nothing to execute. Please run with --start or --stop"
  fi

else
  echo "Nothing to execute. Please run with --dev or --prod"
fi
