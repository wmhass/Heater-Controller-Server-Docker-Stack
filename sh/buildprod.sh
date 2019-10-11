#!/bin/bash
FILE_SOURCE="${BASH_SOURCE[0]}"
while [ -h "$FILE_SOURCE" ]; do # resolve $FILE_SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$FILE_SOURCE" )" && pwd )"
  FILE_SOURCE="$(readlink "$FILE_SOURCE")"
  [[ $FILE_SOURCE != /* ]] && FILE_SOURCE="$DIR/$FILE_SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done

# Check for parameters
PARAMETERS="$@"
if [[ " ${PARAMETERS[@]} " =~ " --all " ]]; then
  PARAMETERS=( --apps_open_api --mqtt_access_control_api --mqtt_broker --mqtt_client_observer --mqtt_http_api --nginx)
fi

# Iterate over parameters and build services repos array
declare -a services_repos
for parameter in "${PARAMETERS[@]}"
do
    case $parameter in
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

for service_repo in ${services_repos[@]}; do
  #Declare vars
  SERVICE_DIR=$SERVICES_REPOS_DIR/$service_repo
  dockerfilename="Dockerfile"
  if [ -f "$SERVICE_DIR/Dockerfile.prod" ]; then
    dockerfilename="Dockerfile.prod"
  fi

  echo "<--- Building " $service_repo
  cd $SERVICE_DIR
  git checkout master
  git pull origin master
  docker build . -f $dockerfilename -t $service_repo:stable
done

exit
