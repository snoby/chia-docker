#!/usr/bin/env bash

docker buildx create --name mybuilder
docker buildx use mybuilder
docker buildx build --platform linux/amd64,linux/arm64 -t gldecurtins/chia-docker:latest --push .
