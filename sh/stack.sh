#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Declare Directories
SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
cd $SCRIPT_DIR/../

# Declare arguments
ARGUMENT_DEV="--dev"
ARGUMENT_PROD="--prod"
ARGUMENT_START="--start"
ARGUMENT_STOP="--stop"

# Declare variables
DOCKER_COMPOSE_DEV_COMMAND="docker-compose -f docker-compose.yml"
DOCKER_COMPOSE_PROD_COMMAND="docker-compose -f docker-compose.prod.yml"
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
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_DEV ]]; then
    # Start
    if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_START ]]; then
      $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE up -d
      $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps
    # Stop
    elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_STOP ]]; then
      $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE down
      $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps
    # No action
    else
      echo "Nothing to execute. Please run with $ARGUMENT_START or $ARGUMENT_STOP"
    fi

# Production
elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PROD ]]; then
    # Start
    if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_START ]]; then
      $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE up -d
      $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps
    # Stop
    elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_STOP ]]; then
      $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE down
      $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps
    # No action
    else
      echo "Nothing to execute. Please run with $ARGUMENT_START or $ARGUMENT_STOP"
    fi
else
  echo "Nothing to execute. Please run with $ARGUMENT_DEV or $ARGUMENT_PROD"
fi
