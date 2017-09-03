#!/usr/bin/env bash
set -e

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
container_name="pf9-monocular-mysql"
mysql_port=3306
mysql_database=monocular
mysql_user=monocular
mysql_password=monocular
mysql_root_password=root

# Start mysql server docker container
function mysql::create_server() {
    mysql_version="$1"
    if [ -z "$mysql_version" ]; then
        echo 'Usage mysql::create_server <mysql version>'
        return 1
    fi
    echo "mysql::create_server: creating test database server (container \`$container_name\`)"

    if [ "$(docker ps --all --quiet --filter "name=$container_name")" ]; then
        echo "mysql::create_server: test database server exists (container \`$container_name\`); skipping"
        return 0
    fi

    # Run container
    cid=$(docker run \
        --name $container_name \
        --detach \
        --net host \
        --env MYSQL_ROOT_PASSWORD=$mysql_root_password \
        --env MYSQL_DATABASE=$mysql_database\
        --env MYSQL_USER=$mysql_user \
        --env MYSQL_PASSWORD=$mysql_password \
        "mysql:${mysql_version}")

    # Wait for mysql server initialization to complete
    echo "mysql::create_server: waiting for database server to initialize"
    grep -q -m 1 "MySQL init process done. Ready for start up." <(docker logs --follow $container_name 2>/dev/null)
    pkill -f "docker logs --follow $container_name"
    # Should probably wait for port to listen here
    sleep 5
}

# Create DB and run migrations
function mysql::init_mysql() {
    set -x
    local migrate="$1"
    if [ -z "${migrate}" ]; then
        echo 'Usage mysql::init_mysql <migrate>'
        return 1
    fi
    mysql -u"${mysql_user}" -p"${mysql_password}" -h127.0.0.1 -P"${mysql_port}" \
        -e "DROP DATABASE IF EXISTS ${mysql_database}; CREATE DATABASE ${mysql_database}"
    "${migrate}" -database "mysql://${mysql_user}:${mysql_password}@tcp(127.0.0.1:${mysql_port})/${mysql_database}" \
        -path "${script_dir}/../storage/mysql/migrations" up
}

# Stop and remove mysql server docker container
function mysql::cleanup_server() {
    echo "mysql::cleanup_server: Cleaning up test database server"

    if [ "$(docker ps --all --quiet --filter "name=$container_name")" ];then
        echo "mysql::cleanup_server: removing container $container_name"
        docker rm -f "$container_name"
    fi
}
