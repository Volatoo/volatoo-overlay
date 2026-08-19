#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
	printf '%s\n' 'Usage: scripts/test-installer-ebuild-docker.sh INSTALLER_REPOSITORY' >&2
	exit 2
fi

repo_root=$(CDPATH='' cd -- "$(dirname -- "$0")/.." && pwd)
installer_root=$(CDPATH='' cd -- "$1" && pwd)

if [ "$(docker context show)" != "orbstack" ]; then
	printf '%s\n' 'error: Docker context must be orbstack' >&2
	exit 1
fi
if [ ! -f "$installer_root/go.mod" ] || [ -L "$installer_root/go.mod" ]; then
	printf '%s\n' 'error: installer repository has no safe go.mod' >&2
	exit 1
fi

"$repo_root/scripts/test-docker.sh"

exec docker run --rm --network none \
	--mount "type=bind,src=$installer_root,dst=/installer,readonly" \
	--entrypoint /bin/bash \
	volatoo-overlay-test:local \
	-c 'set -e
mkdir -p /tmp/installer-source
(cd /installer && tar --exclude=.git -cf - .) | tar -xf - -C /tmp/installer-source
git -C /tmp/installer-source init --quiet
git -C /tmp/installer-source config user.name "Volatoo ebuild test"
git -C /tmp/installer-source config user.email "test@volatoo.invalid"
git -C /tmp/installer-source add .
git -C /tmp/installer-source commit --quiet -m snapshot
mkdir -p /var/cache/distfiles/git3-src
git clone --quiet --mirror /tmp/installer-source /var/cache/distfiles/git3-src/Volatoo_installer.git
chown -R portage:portage /var/cache/distfiles/git3-src
mkdir -p /etc/portage/repos.conf
printf "[volatoo]\nlocation = /var/db/repos/volatoo\nmasters = gentoo\nauto-sync = no\n" > /etc/portage/repos.conf/volatoo.conf
printf "=sys-apps/volatoo-installer-9999 **\n" > /etc/portage/package.accept_keywords/volatoo-installer
mkdir -p /etc/portage/env
printf "EGIT_OVERRIDE_REPO_VOLATOO_INSTALLER=/tmp/installer-source\n" > /etc/portage/env/volatoo-installer.conf
mkdir -p /etc/portage/package.env
printf "=sys-apps/volatoo-installer-9999 volatoo-installer.conf\n" > /etc/portage/package.env/volatoo-installer
emerge --verbose --oneshot =sys-apps/volatoo-installer-9999
/usr/sbin/volatoo-installer version'
