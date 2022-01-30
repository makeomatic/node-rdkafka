#!/usr/bin/env bash

set -ex

if git log --oneline -n 1 | grep -v "chore(release)" > /dev/null; then
  touch .env
  env UID=${UID} PNPM_STORE=$(pnpm config get store-dir) docker-compose --profile tests up -d
  docker-compose exec tester pnpm i
  docker-compose exec tester pnpm test
  docker-compose exec tester pnpm test:e2e
  pnpm semantic-release
else
  echo "skipped commit: `git log --oneline -n 1`"
fi
