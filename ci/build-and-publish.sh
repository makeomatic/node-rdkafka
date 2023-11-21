#!/usr/bin/env bash

set -ex

# To prebuild images for arm platform run these on your local machine
# this would cover everything we need (muslc / libc + 3 node versions)
# Example: NODE_VER=18 platform=-rdkafka ./ci/build-and-publish.sh
# Example: NODE_VER=20 platform=-rdkafka ./ci/build-and-publish.sh
# Example: NODE_VER=21 platform=-rdkafka ./ci/build-and-publish.sh
# Example: NODE_VER=18 platform=-debian-rdkafka ./ci/build-and-publish.sh
# Example: NODE_VER=20 platform=-debian-rdkafka ./ci/build-and-publish.sh
# Example: NODE_VER=21 platform=-debian-rdkafka ./ci/build-and-publish.sh

cp ~/.env.aws-s3-credentials .env
env IMAGE_TAG=${NODE_VER}${platform} UID=${UID} PNPM_STORE=$(pnpm config get store-dir) docker-compose up -d
docker-compose exec tester pnpm i --frozen-lockfile --prefer-offline --ignore-scripts
docker-compose exec tester pnpm binary:build
docker-compose exec tester pnpm binary:package
docker-compose exec tester pnpm binary:test
docker-compose exec tester pnpm binary:publish
