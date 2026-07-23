# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )

inherit git-r3 python-single-r1

DESCRIPTION="Declarative persistence and machine identity for Volatoo"
HOMEPAGE="https://github.com/slchris/Volatoo"
EGIT_REPO_URI="https://github.com/slchris/Volatoo.git"

LICENSE="GPL-2"
SLOT="0"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="
	${PYTHON_DEPS}
	net-misc/openssh
	net-misc/rsync[acl,xattr]
	sys-apps/openrc
	sys-apps/util-linux
"

src_install() {
	python_scriptinto /usr/sbin
	python_doscript \
		persist/volatoo-identity \
		persist/volatoo-persist

	exeinto /usr/libexec
	doexe persist/volatoo-persist-early

	newinitd persist/volatoo-persist.initd volatoo-persist

	dodoc \
		persist/example.conf \
		persist/identity.example.conf \
		docs/design/etc-merge.md \
		docs/design/machine-identity.md \
		docs/design/persistence-policy.md \
		docs/design/state-layout.md
}
