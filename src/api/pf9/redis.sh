#!/usr/bin/env bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
container_name="pf9-monocular-redis"

# Start redis server docker container
function redis::create_server() {
    local redis_image="bitnami/redis"
    local redis_version="3.2.9-r2"
    echo "redis::create_server: creating test redis server (container \`$container_name\`)"

    if [ "$(docker ps --all --quiet --filter "name=$container_name")" ]; then
        echo "redis::create_server: test redis server exists (container \`$container_name\`); skipping"
        return 0
    fi

    # Run container
    cid=$(docker run \
        --name $container_name \
        --detach \
        --net host \
        --env ALLOW_EMPTY_PASSWORD=yes \
        "${redis_image}:${redis_version}")

    # Wait for redis server initialization to complete
    echo "redis::create_server: waiting for redis server to initialize"
    # Should probably wait for port to listen here
    sleep 5
}

# Stop and remove redis server docker container
function redis::cleanup_server() {
    echo "redis::cleanup_server: Cleaning up test redis server"

    if [ "$(docker ps --all --quiet --filter "name=$container_name")" ];then
        echo "redis::cleanup_server: removing container $container_name"
        docker rm -f "$container_name"
    fi
}
