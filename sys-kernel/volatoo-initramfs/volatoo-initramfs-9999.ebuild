# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3

DESCRIPTION="Standalone Volatoo initramfs generator and early userspace"
HOMEPAGE="https://github.com/slchris/Volatoo"
EGIT_REPO_URI="https://github.com/slchris/Volatoo.git"

LICENSE="GPL-2"
SLOT="0"

RDEPEND="
	app-arch/cpio
	app-arch/gzip
	sys-apps/coreutils
	sys-apps/file
	sys-apps/findutils
"

src_prepare() {
	default

	sed -i \
		-e 's|^repo_root=.*|repo_root=/usr/share/volatoo-initramfs|' \
		-e 's|^config_path=.*|config_path=/etc/volatoo/initramfs.conf|' \
		-e 's|^output_path=.*|output_path=/boot/volatoo-initramfs.cpio.gz|' \
		scripts/build-initramfs.sh || die
}

src_install() {
	newbin scripts/build-initramfs.sh volatoo-build-initramfs

	insinto /etc/volatoo
	newins initramfs/default.conf initramfs.conf

	exeinto /usr/share/volatoo-initramfs/initramfs
	doexe initramfs/init

	dodoc initramfs/README.md docs/design/boot.md
}
