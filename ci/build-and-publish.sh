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

if [ x"$CI" = x"true" ]; then
  cp ~/.env.aws-s3-credentials .env
fi
env IMAGE_TAG=${NODE_VER}${platform} UID=${UID} PNPM_STORE="$(dirname `pnpm store path`)" docker-compose up -d
env UID=${UID} docker-compose exec -u ${UID} tester pnpm i --frozen-lockfile --offline --ignore-scripts
env UID=${UID} docker-compose exec -u ${UID} tester pnpm binary:build
env UID=${UID} docker-compose exec -u ${UID} tester pnpm binary:package
env UID=${UID} docker-compose exec -u ${UID} tester pnpm binary:test
env UID=${UID} docker-compose exec -u ${UID} tester pnpm binary:publish
