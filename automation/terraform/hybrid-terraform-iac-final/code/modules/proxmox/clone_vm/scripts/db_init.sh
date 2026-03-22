#!/bin/bash

exec > /tmp/db_init.log 2>&1
set -x

root_pass=$1
schema=$2
app_user=$3
app_password=$4

echo "Install docker"
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
systemctl start docker
systemctl enable docker
dnf install -y nc

echo "Start mysql docker"
mkdir /opt/docker-compose/mysql/data -p

cat <<EOF | tee /opt/docker-compose/mysql/docker-compose.yml
services:
  mysql:
    image: mysql:8.0.45
    container_name: mysql
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "${root_pass}"
      MYSQL_DATABASE: "${schema}"
      MYSQL_USER: "${app_user}"
      MYSQL_PASSWORD: "${app_password}"
    ports:
    - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 5s
      timeout: 5s
      retries: 10
    volumes:
    - "/opt/docker-compose/mysql/data:/var/lib/mysql"
    - "/tmp/tables_init.sql:/tmp/tables_init.sql:ro"
EOF

docker compose -f /opt/docker-compose/mysql/docker-compose.yml up -d

echo "Wait for mysql to be healthy"
count=0
max_retries=60
while [ "$(docker inspect -f '{{.State.Health.Status}}' mysql)" != "healthy" ]; do
	if [ $count -ge $max_retries ]; then
		echo "MySQL container failed to become healthy within $max_retries seconds"
		exit 1
	fi
	sleep 2
	count=$((count+2))
done

echo "Initialize database schema"
while ! nc -z 127.0.0.1 3306; do
    echo "Waiting for MySQL port 3306 to be ready..."
    sleep 2
done
/usr/bin/docker exec mysql mysql -uroot -p${root_pass} -e "CREATE DATABASE IF NOT EXISTS ${schema};"
/usr/bin/docker exec mysql cat /tmp/tables_init.sql
/usr/bin/docker exec mysql mysql -uroot -p${root_pass} -e 'show databases;'
/usr/bin/docker exec mysql mysql -uroot -p${root_pass} "${schema}" -e 'source /tmp/tables_init.sql' 
/usr/bin/docker exec mysql mysql -uroot -p${root_pass} "${schema}" -e 'show tables;'