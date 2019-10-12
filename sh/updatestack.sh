#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

BUILD="0"
PULL="0"
BUILD_TAG="stable"
# Check for Arguments
ARGUMENTS=( $@ )
if [[ " ${ARGUMENTS[@]} " =~ "--build" ]]; then
  BUILD="1"
fi
if [[ " ${ARGUMENTS[@]} " =~ "--pull" ]]; then
  PULL="1"
fi

# Check for Tag argument
for argument in "${ARGUMENTS[@]}"
do
  if [[ $argument =~ --tag=(.*)[1,+] ]]; then
    BUILD_TAG=`echo $argument | sed -e "s/\-\-tag\=//g"`
    break
  fi
done

# Check for Services
SERVICES=( $@ )
if [[ " ${SERVICES[@]} " =~ "--all" ]]; then
  SERVICES=( --apps_open_api --mqtt_access_control_api --mqtt_broker --mqtt_client_observer --mqtt_http_api --nginx)
fi

# Iterate over services and build services repos array
declare -a services_repos
for service in "${SERVICES[@]}"
do
    case $service in
        --apps_open_api)
        services_repos+=( "apps_open_api" )
        ;;

        --mqtt_access_control_api)
        services_repos+=( "mqtt_access_control_api" )
        ;;

        --mqtt_broker)
        services_repos+=( "mqtt_broker" )
        ;;

        --mqtt_client_observer)
        services_repos+=( "mqtt_client_observer" )
        ;;

        --mqtt_http_api)
        services_repos+=( "mqtt_http_api" )
        ;;

        --nginx)
        services_repos+=( "nginx" )
        ;;

        *)
        ;;
    esac
done

# Declare variabls
SCRIPT_DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
SERVICES_REPOS_DIR=$SCRIPT_DIR/../services_repos

# Iterate over services
for service_repo in ${services_repos[@]}; do
  #Declare vars
  SERVICE_DIR=$SERVICES_REPOS_DIR/$service_repo
  dockerfilename="Dockerfile"
  if [ -f "$SERVICE_DIR/Dockerfile.prod" ]; then
    dockerfilename="Dockerfile.prod"
  fi
  echo ""
  echo "<-- Service $service_repo"
  cd $SERVICE_DIR

  if [[ $PULL == "1" ]]; then
    echo "<<------ Pulling "$service_repo
    git checkout master
    git pull origin master
  fi

  if [[ $BUILD == "1" ]]; then
    echo "<<------ Building "$service_repo
    docker build . -f $dockerfilename -t $service_repo"_service":$BUILD_TAG
  fi
  echo ""
done
