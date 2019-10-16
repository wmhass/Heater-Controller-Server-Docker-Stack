#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Declare Directories
SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
ENVIRONMENT_DEV_DIR=$SCRIPT_DIR/../environments/dev
ENVIRONMENT_PROD_DIR=$SCRIPT_DIR/../environments/prod

# Declare arguments
ARGUMENT_DEV="--dev"
ARGUMENT_PROD="--prod"
ARGUMENT_START="--start"
ARGUMENT_STOP="--stop"

DEFAULT_PROD_TAG="stable"
DEFAULT_DEV_TAG="latest"
TAG_PARAM=""

# Declare variables
DOCKER_COMPOSE_DEV_COMMAND="docker-compose -f docker-compose.yml"
DOCKER_COMPOSE_PROD_COMMAND="docker-compose -f docker-compose.prod.yml"
ARGUMENTS="$@"

# Check for --override argument
OVERRIDE_DOCKER_COMPOSE_FILE=""
for argument in "${ARGUMENTS[@]}"
do
  # Override tag
  if [[ $argument =~ --override=(.*) ]]; then
    override_result=`echo $argument | sed -e "s/.*\-\-override\=//g"`
    if [[ ${#override_result} -gt 0 ]]; then
      OVERRIDE_DOCKER_COMPOSE_FILE=" -f $override_result "
     fi
  fi
  # Build tag
  if [[ $argument =~ --tag=(.*) ]]; then
    tag_result=`echo $argument | sed -e "s/.*\-\-tag\=//g"`
    if [[ ${#tag_result} -gt 0 ]]; then
       TAG_PARAM=$tag_result
     fi
  fi
done

# Development
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_DEV ]]; then
    cd $ENVIRONMENT_DEV_DIR
    echo "!!!!!! - ENV:: $ENVIRONMENT_DEV_DIR"
    TAG=$DEFAULT_DEV_TAG
    if [[ ${#TAG_PARAM} -gt 0 ]]; then
       TAG=$TAG_PARAM
    fi
    # Start
    if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_START ]]; then
      export TAG=$TAG; $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE up -d
    # Stop
    elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_STOP ]]; then
      export TAG=$TAG; $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE down
    # No action
    else
      echo "Nothing to execute. Please run with $ARGUMENT_START or $ARGUMENT_STOP"
    fi
    $DOCKER_COMPOSE_DEV_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps

# Production
elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PROD ]]; then
    cd $ENVIRONMENT_PROD_DIR
    TAG=$DEFAULT_PROD_TAG
    if [[ ${#TAG_PARAM} -gt 0 ]]; then
       TAG=$TAG_PARAM
    fi
    echo "TAG: $TAG"
    # Start
    if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_START ]]; then
      export TAG=$TAG; $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE up -d
    # Stop
    elif [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_STOP ]]; then
      export TAG=$TAG; $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE down
    # No action
    else
      echo "Nothing to execute. Please run with $ARGUMENT_START or $ARGUMENT_STOP"
    fi
    $DOCKER_COMPOSE_PROD_COMMAND $OVERRIDE_DOCKER_COMPOSE_FILE ps
else
  echo "Nothing to execute. Please run with $ARGUMENT_DEV or $ARGUMENT_PROD"
fi
