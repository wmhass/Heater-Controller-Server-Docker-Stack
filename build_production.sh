#!/bin/bash
cd ./services_repos

cd mqtt_access_control_api
git checkout master
git pull origin master
docker build . -f Dockerfile.prod -t mqtt_access_control_api_service:stable
#docker push registry-host:5000/myadmin/mqtt_access_control_api_service:stable

cd ../apps_open_api
git checkout master
git pull origin master
docker build . -f Dockerfile.prod -t apps_open_api_service:stable
#docker push registry-host:5000/myadmin/apps_open_api_service:stable

cd ../nginx
git checkout master
git pull origin master
docker build . -f Dockerfile -t nginx_service:stable
#docker push registry-host:5000/myadmin/nginx_service:stable

cd ../mqtt_broker
git checkout master
git pull origin master
docker build . -f Dockerfile -t mqtt_broker_service:stable
# docker push registry-host:5000/myadmin/mqtt_broker_service:stable

cd ../mqtt_client_observer
git checkout master
git pull origin master
docker build . -f Dockerfile -t mqtt_client_observer_service:stable
#docker push registry-host:5000/myadmin/mqtt_client_observer_service:stable

cd ../mqtt_http_api
git checkout master
git pull origin master
docker build . -f Dockerfile -t mqtt_http_api_service:stable
#docker push registry-host:5000/myadmin/mqtt_http_api_service:stable
