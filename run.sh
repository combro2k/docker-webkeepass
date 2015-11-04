#!/bin/bash

docker run \
    -ti \
    --rm \
    --name webkeepass \
    --expose 5001 \
    -p 5001:5001 \
    -v $(pwd)/resources/data:/data \
    -v $(pwd)/resources/srv/webkeepass/environments/production.yml:/srv/webkeepass/environments/production.yml \
    combro2k/webkeepass:latest ${@}
