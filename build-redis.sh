#!/bin/bash

. mailcow.conf
./build-network.sh

NAME="redis-mailcow"

client() {
    docker exec -it ${NAME} /bin/bash -c "redis-cli"
}

if [[  ${1} == "--client" ]]; then
    client
	exit 0
fi

echo "Stopping and removing containers with name tag ${NAME}..."
if [[ ! -z $(docker ps -af "name=${NAME}" -q) ]]; then
    docker stop $(docker ps -af "name=${NAME}" -q)
    docker rm $(docker ps -af "name=${NAME}" -q)
fi

if [[ ! -z "$(docker images -q redis:${DBVERS})" ]]; then
    read -r -p "Found image locally. Rebuild/pull anyway? [y/N] " response
    response=${response,,}
    if [[ $response =~ ^(yes|y)$ ]]; then
        docker rmi redis:${DBVERS}
    fi
fi

docker run \
	-v ${PWD}/data/db/redis/:/data/ \
	--network=${DOCKER_NETWORK} \
	-h redis \
	--network-alias redis \
	--name=${NAME} \
	-d redis:${REDISVERS} --appendonly yes