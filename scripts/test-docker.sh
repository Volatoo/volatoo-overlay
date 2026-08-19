#!/bin/sh
set -eu

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)

if [ "$(docker context show)" != "orbstack" ]; then
	printf '%s\n' 'error: Docker context must be orbstack' >&2
	exit 1
fi

exec docker build \
	--file "$repo_root/Dockerfile.test" \
	--tag volatoo-overlay-test:local \
	"$repo_root"
