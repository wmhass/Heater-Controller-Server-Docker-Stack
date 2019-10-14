#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"

cd $SCRIPT_DIR/../

# Check for ARGUMENTS
ARGUMENTS="$@"

# Check for --override argument
OVERRIDE_DOCKER_COMPOSE_FILE=""
for argument in "${ARGUMENTS[@]}"
do
  if [[ $argument =~ --override=(.*) ]]; then
    override_result=`echo $argument | sed -e "s/.*\-\-override\=//g"`
    if [[ ${#override_result} -gt 0 ]]; then
      OVERRIDE_DOCKER_COMPOSE_FILE=" -f $override_result "
     fi
  fi
done

# Development
if [[ " ${ARGUMENTS[@]} " =~ " --dev " ]]; then

  # Start Development
  if [[ " ${ARGUMENTS[@]} " =~ " --start " ]]; then
    docker-compose -f docker-compose.yml $OVERRIDE_DOCKER_COMPOSE_FILE up -d
    docker-compose -f docker-compose.yml $OVERRIDE_DOCKER_COMPOSE_FILE ps
  # Stop Development
  elif [[ " ${ARGUMENTS[@]} " =~ " --stop " ]]; then
    docker-compose -f docker-compose.yml $OVERRIDE_DOCKER_COMPOSE_FILE down
    docker-compose -f docker-compose.yml $OVERRIDE_DOCKER_COMPOSE_FILE ps
  # No action
  else
    echo "Nothing to execute. Please run with --start or --stop"
  fi

# Production
elif [[ " ${ARGUMENTS[@]} " =~ " --prod " ]]; then

  # Start Production
  if [[ " ${ARGUMENTS[@]} " =~ " --start " ]]; then
    docker-compose -f docker-compose.prod.yml $OVERRIDE_DOCKER_COMPOSE_FILE up -d
    docker-compose -f docker-compose.prod.yml $OVERRIDE_DOCKER_COMPOSE_FILE ps
  # Stop Production
  elif [[ " ${ARGUMENTS[@]} " =~ " --stop " ]]; then
    docker-compose -f docker-compose.prod.yml $OVERRIDE_DOCKER_COMPOSE_FILE down
    docker-compose -f docker-compose.prod.yml $OVERRIDE_DOCKER_COMPOSE_FILE ps
  # No action
  else
    echo "Nothing to execute. Please run with --start or --stop"
  fi

else
  echo "Nothing to execute. Please run with --dev or --prod"
fi
