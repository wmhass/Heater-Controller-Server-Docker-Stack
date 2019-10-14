#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Declare directories
SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
SERVICES_REPOS_DIR=$SCRIPT_DIR/../services_repos

# Declare arguments
ARGUMENT_PULL_GITHUB_REPO="--pull-github-repo"
ARGUMENT_BUILD_DOCKER_IMAGES="--build-docker-images"
ARGUMENT_PULL_DOCKER_IMAGES="--pull-docker-image"
ARGUMENT_SERVICE_APPS_OPEN_API="--apps_open_api"
ARGUMENT_SERVICE_MQTT_ACCESS_CONTROL_API="--mqtt_access_control_api"
ARGUMENT_SERVICE_MQTT_BROKER="--mqtt_broker"
ARGUMENT_SERVICE_MQTT_CLIENT_OBSERVER="--mqtt_client_observer"
ARGUMENT_SERVICE_MQTT_HTTP_API="--mqtt_http_api"
ARGUMENT_SERVICE_NGINX="--nginx"

# Declare service names
SERVICE_NAME_APPS_OPEN_API="apps_open_api"
SERVICE_NAME_MQTT_ACCESS_CONTROL_API="mqtt_access_control_api"
SERVICE_NAME_MQTT_BROKER="mqtt_broker"
SERVICE_NAME_MQTT_CLIENT_OBSERVER="mqtt_client_observer"
SERVICE_NAME_MQTT_HTTP_API="mqtt_http_api"
SERVICE_NAME_NGINX="nginx"

# Declare variables
DOCKER_IMAGE_BUILD_TAG="stable"
GIT_BRANCH="master"

# Declare flags
FLAG_BUILD="0"
FLAG_PULL_GITHUB_REPO="0"
FLAG_PULL_DOCKER_IMAGE="0"

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

# Check for Tag argument
for argument in "${ARGUMENTS[@]}"
do
  # Build tag
  if [[ $argument =~ --tag=(.*) ]]; then
    tag_result=`echo $argument | sed -e "s/.*\-\-tag\=//g"`
    if [[ ${#tag_result} -gt 0 ]]; then
       DOCKER_IMAGE_BUILD_TAG=$tag_result
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
declare -a services_repos
for service in "${SERVICES[@]}"
do
    case $service in
        $ARGUMENT_SERVICE_APPS_OPEN_API)
        services_repos+=( $SERVICE_NAME_APPS_OPEN_API )
        ;;

        $ARGUMENT_SERVICE_MQTT_ACCESS_CONTROL_API)
        services_repos+=( $SERVICE_NAME_MQTT_ACCESS_CONTROL_API )
        ;;

        $ARGUMENT_SERVICE_MQTT_BROKER)
        services_repos+=( $SERVICE_NAME_MQTT_BROKER )
        ;;

        $ARGUMENT_SERVICE_MQTT_CLIENT_OBSERVER)
        services_repos+=( $SERVICE_NAME_MQTT_CLIENT_OBSERVER )
        ;;

        $ARGUMENT_SERVICE_MQTT_HTTP_API)
        services_repos+=( $SERVICE_NAME_MQTT_HTTP_API )
        ;;

        $ARGUMENT_SERVICE_NGINX)
        services_repos+=( $SERVICE_NAME_NGINX )
        ;;

        *)
        ;;
    esac
done

# Iterate over services
for service_repo in ${services_repos[@]}; do
  #Declare vars
  SERVICE_DIR=$SERVICES_REPOS_DIR/$service_repo
  dockerfilename="Dockerfile"
  if [ -f "$SERVICE_DIR/Dockerfile.prod" ]; then
    dockerfilename="Dockerfile.prod"
  fi
  echo "<-- Service $service_repo"

  if [[ $FLAG_PULL_DOCKER_IMAGE == "1" ]]; then
    echo "<<------ Pulling Docker Image for "$service_repo
    # TODO: docker pull image...
    # docker pull my-registry:9000/mqtt_http_api_service:stable
  fi

  if [[ $FLAG_PULL_GITHUB_REPO == "1" ]]; then
    echo "<<------ Pulling Github Repository for "$service_repo
    cd $SERVICE_DIR
    git checkout $GIT_BRANCH
    git pull origin $GIT_BRANCH
  fi

  if [[ $FLAG_BUILD == "1" ]]; then
    echo "<<------ Building "$service_repo
    cd $SERVICE_DIR
    docker build . -f $dockerfilename -t $service_repo"_service":$DOCKER_IMAGE_BUILD_TAG
  fi
  echo ""
done
