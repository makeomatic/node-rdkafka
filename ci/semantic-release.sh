#!/usr/bin/env bash

set -ex

if git log --oneline -n 1 | grep -v "chore(release)" > /dev/null; then
  touch .env
  env UID=${UID} PNPM_STORE=$(dirname `pnpm store path`) docker-compose --profile tests up -d
  env UID=${UID} docker-compose exec -u ${UID} tester pnpm i --frozen-lockfile --offline --ignore-scripts
  env UID=${UID} docker-compose exec -u ${UID} tester pnpm binary:build
  env UID=${UID} docker-compose exec -u ${UID} tester pnpm test
  env UID=${UID} docker-compose exec -u ${UID} tester pnpm test:e2e
  pnpm semantic-release
else
  echo "skipped commit: `git log --oneline -n 1`"
fi
