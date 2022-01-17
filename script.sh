#!/bin/bash
export $(cat app.env | xargs )
mkdir -p $DAT_VOLUME

docker build -t text-search .
# docker network create text-app
# docker rm -f mongo text-search mongodb
# export MONGO_DB=db MONGO_PORT=5000 MONGO_USER=MONGO MONGO_PASSWORD=MONGO
docker rm -f text-search mongodb
docker run  -d -v $DAT_VOLUME:/data/db --name mongodb -p $DAT_PORT:27017 \
    -e MONGO_INITDB_ROOT_USERNAME=$DB_USER \
    -e MONGO_INITDB_ROOT_PASSWORD=$DB_PASSWORD \
    -e MONGO_INITDB_DATABASE=$DB_DATABASE \
    mongo
DAT_HOST=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' mongodb )
docker run  --name text-search --env-file  ./app.env -e DAT_HOST=$DAT_HOST -p $APP_PORT:$APP_PORT  text-search

