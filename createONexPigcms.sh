#!/bin/bash
set -e
source config

NGINX_CONF=default.conf

# Start ONex
docker run \
--name ${ONEX_NAME} \
-v ${ONEX_SOURCE}:/var/www/html \
-d ${ONEX_IMAGE}

while [ -z "$(docker logs ${ONEX_NAME} 2>&1 | grep 'apache2 -D FOREGROUND')" ]; do
    echo "Waiting onex ready."
    sleep 1
done

# Start Mysql volume
docker run \
--name ${PIGCMS_MYSQL_VOLUME} \
-d ${MYSQL_IMAGE} \
echo "mysql volume"

# Start Mysql
docker run \
--name ${PIGCMS_MYSQL} \
-P \
-e MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD} \
-e MYSQL_DATABASE=${MYSQL_DATABASE} \
-e MYSQL_USER=${MYSQL_USER} \
-e MYSQL_PASSWORD=${MYSQL_PASSWORD} \
--volumes-from ${PIGCMS_MYSQL_VOLUME} \
-d ${MYSQL_IMAGE}

while [ -z "$(docker logs ${PIGCMS_MYSQL} 2>&1 | grep 'port: 3306')" ]; do
    echo "Waiting mysql ready."
    sleep 1
done

# Start Pigcms
docker run \
--name ${PIGCMS_NAME} \
-v ${PIGCMS_SOURCE}:/var/www/html \
-d ${PIGCMS_IMAGE}

while [ -z "$(docker logs ${PIGCMS_NAME} 2>&1 | grep 'apache2 -D FOREGROUND')" ]; do
    echo "Waiting pigcms ready."
    sleep 1
done

sed "s/{ONEX_URL}/${ONEX_URL}/g" $(pwd)/${NGINX_CONF}.template > $(pwd)/${NGINX_CONF}
sed -i "s/{PIGCMS_URL}/${PIGCMS_URL}/g" $(pwd)/${NGINX_CONF}

# Start Nginx
docker run \
-p 80:80 \
--name ${NGINX_NAME} \
--link ${ONEX_NAME}:${ONEX_NAME} \
--link ${PIGCMS_NAME}:${PIGCMS_NAME} \
-v $(pwd)/${NGINX_CONF}:/etc/nginx/conf.d/default.conf \
-d ${NGINX_IMAGE_NAME}

