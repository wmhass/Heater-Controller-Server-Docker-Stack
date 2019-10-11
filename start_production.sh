#!/bin/bash

# docker pull my-registry:9000/mqtt_access_control_api_service:stable
# docker pull my-registry:9000/apps_open_api_service:stable
# docker pull my-registry:9000/nginx_service:stable
# docker pull my-registry:9000/mqtt_broker_service:stable
# docker pull my-registry:9000/mqtt_client_observer_service:stable
# docker pull my-registry:9000/mqtt_http_api_service:stable


docker-compose -f docker-compose.prod.yml up -d
