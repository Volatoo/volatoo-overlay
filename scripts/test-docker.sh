#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
# shellcheck source=scripts/require-docker-context.sh
. "$repo_root/scripts/require-docker-context.sh"
volatoo_require_docker_context

exec docker build \
	--file "$repo_root/Dockerfile.test" \
	--tag volatoo-overlay-test:local \
	"$repo_root"
