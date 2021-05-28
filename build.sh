#!/bin/bash
set -xe
source version.txt
docker build --build-arg http_proxy=http://apt-cacher.mattsnoby.com:3142 \
	--build-arg CHIA_VERSION=$CHIA_VERSION  . \
       	-t "${CONTAINER_NAME_LATEST}"

