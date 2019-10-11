# Git clone
git clone --recurse-submodules /Users/william/Developer/infra-poc/vm/Heater-Controller-Env-Virtual-Machine

# Override docker-compose
https://medium.com/softonic-eng/docker-compose-from-development-to-production-88000124a57c

# Docker stack deploy
docker stack deploy -c docker-compose.yml stacktest

# Docker
- docker system prune -a
- docker volume prune
- docker volume ls
- docker logs [container name] (https://medium.com/@pimterry/5-ways-to-debug-an-exploding-docker-container-4f729e2c0aa8)

# Helpers
- docker-compose logs -f
- docker stop $(docker ps -a -q)
- docker rm $(docker ps -a -q)



# Development
- docker-compose up -d --build
- docker-compose exec web python manage.py makemigrations historical_data --noinput
- docker-compose exec web python manage.py migrate --noinput
- docker-compose exec web python manage.py migrate --fake mqttauthorization zero
- docker build services/heater_control_app --file services/heater_control_app/Dockerfile --tag heater_control:dev_stable
- docker-compose exec mqttauthorization python manage.py migrate --fake authorizationapi zero

# Production
- docker-compose -f docker-compose.prod.yml up -d --build
- docker-compose -f docker-compose.prod.yml up -d
- docker-compose -f docker-compose.prod.yml exec
- docker-compose -f docker-compose.prod.yml down -v
- docker build services/heater_control_app --file services/heater_control_app/Dockerfile.prod --tag heater_control:master_stable

# Exec command
docker-compose -f docker-compose.prod.yml exec web python manage.py migrate --noinput
docker-compose -f docker-compose.prod.yml exec web python manage.py collectstatic --no-input --clear


# MQTT Broker
docker-compose exec mqttbroker kill -SIGHUP 1
  -> This command will have the mosquitto mqtt broker to reload the configuration file

# Build
docker build -t mqtt_access_control_api:latest
docker build . -f Dockerfile.prod -t mqtt_access_control_api:stable
build ../services_repos/apps_open_api -f ../services_repos/apps_open_api/
Dockerfile.prod -t apps_open_api:stable



# Links Dev
## apps_open_api service
http://127.0.0.1:8000/
http://127.0.0.1:8000/admin

## mqtt_access_control_api service
http://127.0.0.1:8001/mqtt_access_control_api/
http://127.0.0.1:8001/mqtt_access_control_api/admin
http://127.0.0.1:8001/mqtt_access_control_api/accounts/
http://127.0.0.1:8001/mqtt_access_control_api/accounts/1

## mqtt_http_api service
http://127.0.0.1:8888/mqtt_http_api/
Expect answer in: hello/debug1

## mqtt_observer service
Publish to: say/hello
Expect answer in: hello/debug1

# Links Prod
## apps_open_api service
http://127.0.0.1:1337/
http://127.0.0.1:1337/admin

## mqtt_access_control_api service [This api is not exposed to outside of the docker network]
http://127.0.0.1:1337/mqtt_access_control_api/
http://127.0.0.1:1337/mqtt_access_control_api/admin
http://127.0.0.1:1337/mqtt_access_control_api/accounts/
http://127.0.0.1:1337/mqtt_access_control_api/accounts/1

## mqtt_http_api service
http://127.0.0.1:1337/mqtt_http_api/
Expect answer in: hello/debug1

## mqtt_observer service
Publish to: say/hello
Expect answer in: hello/debug1
