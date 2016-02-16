#!/bin/bash
set -e
source config

docker stop ${NGINX_NAME}
docker stop ${ONEX_NAME}
docker stop ${PIGCMS_NAME}
docker stop ${PIGCMS_MYSQL}
docker rm -v ${NGINX_NAME}
docker rm -v ${ONEX_NAME}
docker rm -v ${PIGCMS_NAME}
docker rm -v ${PIGCMS_MYSQL}
docker rm -v ${PIGCMS_MYSQL_VOLUME}
