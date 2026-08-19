# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Authenticated explicit-device installer for Volatoo"
HOMEPAGE="https://github.com/Volatoo/installer"
EGIT_REPO_URI="https://github.com/Volatoo/installer.git"

LICENSE="GPL-2"
SLOT="0"

BDEPEND=">=dev-lang/go-1.24"
RDEPEND="
	app-arch/zstd
	app-misc/ca-certificates
	sys-apps/coreutils
	sys-apps/gptfdisk
	sys-apps/util-linux
	sys-fs/e2fsprogs
"

src_compile() {
	CGO_ENABLED=0 go build \
		-trimpath \
		-ldflags="-buildid= -X main.version=${PV}" \
		-o volatoo-installer \
		./cmd/volatoo-installer
}

src_install() {
	dosbin volatoo-installer
	dodoc README.md docs/installer-v1.md
}
