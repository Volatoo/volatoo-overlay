#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
	printf '%s\n' 'Usage: scripts/test-installer-ebuild-docker.sh INSTALLER_REPOSITORY' >&2
	exit 2
fi

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
installer_root=$(CDPATH='' cd -- "$1" && pwd)
# shellcheck source=scripts/require-docker-context.sh
. "$repo_root/scripts/require-docker-context.sh"
volatoo_require_docker_context
if [ ! -f "$installer_root/go.mod" ] || [ -L "$installer_root/go.mod" ]; then
	printf '%s\n' 'error: installer repository has no safe go.mod' >&2
	exit 1
fi

fixture_root=$(mktemp -d "${TMPDIR:-/tmp}/volatoo-installer-ebuild.XXXXXX")
cleanup()
{
	rm -rf -- "$fixture_root"
}
trap cleanup 0 HUP INT TERM

(cd "$installer_root" && tar --exclude=.git -cf - .) |
	tar -xf - -C "$fixture_root"
[ ! -e "$fixture_root/.git" ]
git init --quiet "$fixture_root"
git -C "$fixture_root" config user.name "Volatoo ebuild test"
git -C "$fixture_root" config user.email "test@volatoo.invalid"
git -C "$fixture_root" add .
git -C "$fixture_root" commit --quiet -m snapshot

"$repo_root/scripts/test-docker.sh"

docker run --rm --network none \
	--mount "type=bind,src=$fixture_root,dst=/installer,readonly" \
	--entrypoint /bin/bash \
	volatoo-overlay-test:local \
	-c 'set -e
mkdir -p /var/cache/distfiles/git3-src
git clone --quiet --mirror /installer /var/cache/distfiles/git3-src/Volatoo_installer.git
chown -R portage:portage /var/cache/distfiles/git3-src
mkdir -p /etc/portage/repos.conf
printf "[volatoo]\nlocation = /var/db/repos/volatoo\nmasters = gentoo\nauto-sync = no\n" > /etc/portage/repos.conf/volatoo.conf
printf "=sys-apps/volatoo-installer-9999 **\n" > /etc/portage/package.accept_keywords/volatoo-installer
mkdir -p /etc/portage/env
printf "EGIT_OVERRIDE_REPO_VOLATOO_INSTALLER=/installer\n" > /etc/portage/env/volatoo-installer.conf
mkdir -p /etc/portage/package.env
printf "=sys-apps/volatoo-installer-9999 volatoo-installer.conf\n" > /etc/portage/package.env/volatoo-installer
emerge --verbose --oneshot =sys-apps/volatoo-installer-9999
/usr/sbin/volatoo-installer version'
