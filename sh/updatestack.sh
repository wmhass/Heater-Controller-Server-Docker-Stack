#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Declare directories
SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
ENVIRONMENT_PROD_DIR=$SCRIPT_DIR/../environments/prod
DOCKER_COMPOSE_FILE_PROD="docker-compose.prod.yml"
DOCKER_COMPOSE_FILE_BUILD_PROD="docker-compose.build.prod.yml"
ENVIRONMENT_DEV_DIR=$SCRIPT_DIR/../environments/dev
SERVICES_REPOS_DIR=$ENVIRONMENT_DEV_DIR/services_repos

# Declare arguments
ARGUMENT_PULL_GITHUB_REPO="--pull-github-repo"
ARGUMENT_BUILD_DOCKER_IMAGES="--build"
ARGUMENT_PUSH_DOCKER_IMAGES="--push-image"
ARGUMENT_PULL_DOCKER_IMAGES="--pull-image"
ARGUMENT_SERVICE_APPS_OPEN_API="--apps_open_api"
ARGUMENT_SERVICE_MQTT_ACCESS_CONTROL_API="--mqtt_access_control_api"
ARGUMENT_SERVICE_MQTT_BROKER="--mqtt_broker"
ARGUMENT_SERVICE_MQTT_CLIENT_OBSERVER="--mqtt_client_observer"
ARGUMENT_SERVICE_MQTT_HTTP_API="--mqtt_http_api"
ARGUMENT_SERVICE_NGINX="--nginx"
ARGUMENT_PROD="--prod"

# Declare service names
SERVICE_NAME_APPS_OPEN_API="apps_open_api"
SERVICE_NAME_MQTT_ACCESS_CONTROL_API="mqtt_access_control_api"
SERVICE_NAME_MQTT_BROKER="mqtt_broker"
SERVICE_NAME_MQTT_CLIENT_OBSERVER="mqtt_client_observer"
SERVICE_NAME_MQTT_HTTP_API="mqtt_http_api"
SERVICE_NAME_NGINX="nginx"

# Declare variables
DOCKER_IMAGE_TAG_PARAM=""
GIT_BRANCH="master"
DEFAULT_DEV_TAG="latest"
DEFAULT_PROD_TAG="stable"

# Declare flags
FLAG_BUILD="0"
FLAG_PULL_GITHUB_REPO="0"
FLAG_PULL_DOCKER_IMAGE="0"
FLAG_PUSH_DOCKER_IMAGE="0"
FLAG_IS_PROD="0"

# Check for Arguments
ARGUMENTS=( $@ )
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_BUILD_DOCKER_IMAGES ]]; then
  FLAG_BUILD="1"
fi
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PULL_GITHUB_REPO ]]; then
  FLAG_PULL_GITHUB_REPO="1"
fi
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PULL_DOCKER_IMAGES ]]; then
  FLAG_PULL_DOCKER_IMAGE="1"
fi
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PUSH_DOCKER_IMAGES ]]; then
  FLAG_PUSH_DOCKER_IMAGE="1"
fi
if [[ " ${ARGUMENTS[@]} " =~ $ARGUMENT_PROD ]]; then
  FLAG_IS_PROD="1"
fi

# Check for Tag argument
for argument in "${ARGUMENTS[@]}"
do
  # Build tag
  if [[ $argument =~ --tag=(.*) ]]; then
    tag_result=`echo $argument | sed -e "s/.*\-\-tag\=//g"`
    if [[ ${#tag_result} -gt 0 ]]; then
       DOCKER_IMAGE_TAG_PARAM=$tag_result
     fi
  fi
  # Git Branch
  if [[ $argument =~ --branch=(.*) ]]; then
    branch_result=`echo $argument | sed -e "s/.*\-\-branch\=//g"`
    if [[ ${#branch_result} -gt 0 ]]; then
       GIT_BRANCH=$branch_result
     fi
  fi
done

# Check for Services
SERVICES=( $@ )
if [[ " ${SERVICES[@]} " =~ "--all" ]]; then
  SERVICES=( $ARGUMENT_SERVICE_APPS_OPEN_API $ARGUMENT_SERVICE_MQTT_ACCESS_CONTROL_API $ARGUMENT_SERVICE_MQTT_BROKER $ARGUMENT_SERVICE_MQTT_CLIENT_OBSERVER $ARGUMENT_SERVICE_MQTT_HTTP_API $ARGUMENT_SERVICE_NGINX)
fi

# Iterate over services and build services repos array
declare -a services_names
for service in "${SERVICES[@]}"
do
    case $service in
        $ARGUMENT_SERVICE_APPS_OPEN_API)
        services_names+=( $SERVICE_NAME_APPS_OPEN_API )
        ;;

        $ARGUMENT_SERVICE_MQTT_ACCESS_CONTROL_API)
        services_names+=( $SERVICE_NAME_MQTT_ACCESS_CONTROL_API )
        ;;

        $ARGUMENT_SERVICE_MQTT_BROKER)
        services_names+=( $SERVICE_NAME_MQTT_BROKER )
        ;;

        $ARGUMENT_SERVICE_MQTT_CLIENT_OBSERVER)
        services_names+=( $SERVICE_NAME_MQTT_CLIENT_OBSERVER )
        ;;

        $ARGUMENT_SERVICE_MQTT_HTTP_API)
        services_names+=( $SERVICE_NAME_MQTT_HTTP_API )
        ;;

        $ARGUMENT_SERVICE_NGINX)
        services_names+=( $SERVICE_NAME_NGINX )
        ;;

        *)
        ;;
    esac
done

# Iterate over services
for service_name in ${services_names[@]}; do
  #Declare vars
  SERVICE_DIR=$SERVICES_REPOS_DIR/$service_name
  echo "<-- Service $service_name"

  # Pull Docker Image
  if [[ $FLAG_PULL_DOCKER_IMAGE == "1" ]]; then
    echo "<<------ Pulling Docker Image for "$service_name
    # TODO: docker pull image...
    # docker pull my-registry:9000/mqtt_http_api_service:stable
  fi

  # Pull Github CHanges
  if [[ $FLAG_PULL_GITHUB_REPO == "1" ]]; then
    echo "<<------ Pulling Github Repository for "$service_name
    cd $SERVICE_DIR
    git checkout $GIT_BRANCH
    git pull origin $GIT_BRANCH
  fi

  # Build
  if [[ $FLAG_BUILD == "1" ]]; then
    echo "<<------ Building docker image "$service_name
    # Build Production
    if [ $FLAG_IS_PROD == "0" ]; then
      cd $ENVIRONMENT_PROD_DIR
      TAG=$DEFAULT_PROD_TAG
      if [[ ${#DOCKER_IMAGE_TAG_PARAM} -gt 0 ]]; then
         TAG=$DOCKER_IMAGE_TAG_PARAM
      fi
      CODEPATH=$SERVICES_REPOS_DIR TAG=$TAG docker-compose -f $DOCKER_COMPOSE_FILE_PROD -f $DOCKER_COMPOSE_FILE_BUILD_PROD build $service_name
    # Build Development
    else
      cd $ENVIRONMENT_DEV_DIR
      TAG=$DEFAULT_DEV_TAG
      if [[ ${#DOCKER_IMAGE_TAG_PARAM} -gt 0 ]]; then
         TAG=$DOCKER_IMAGE_TAG_PARAM
      fi
      TAG=$TAG docker-compose build $service_name
    fi

    # Push docker image
    if [[ $FLAG_PUSH_DOCKER_IMAGE == "1" ]]; then
      echo "<<------ Pushing docker image "$service_name
      # TODO: Push docker images
    fi
  fi
  echo ""
done
