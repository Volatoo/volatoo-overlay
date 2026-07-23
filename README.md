# Volatoo Gentoo overlay

Official Portage overlay for [Volatoo](https://github.com/slchris/Volatoo), a
Gentoo-based distribution that copies its root filesystem into tmpfs at boot.

The overlay currently provides live ebuilds for:

- `sys-kernel/volatoo-initramfs`: the standalone initramfs generator and early
  userspace;
- `sys-apps/volatoo-persist`: persistence, machine identity, and its OpenRC
  shutdown service.

Live ebuilds track the Volatoo default branch and intentionally have no
keywords. Versioned ebuilds will be added when Volatoo publishes source
releases.

> [!IMPORTANT]
> The initial Volatoo implementation is published on its development branch
> but has not yet landed on the default branch. Both ebuilds passed real
> Portage installation tests against commit
> `87ca6fe41178e0028b665f88deec6f76e4f7fbb6`; default-branch installation
> remains blocked until that change is merged.

## Add the repository

Install `app-eselect/eselect-repository`, then run:

```sh
eselect repository add volatoo git \
  https://github.com/slchris/volatoo-overlay.git
emaint sync -r volatoo
```

Allow the live packages explicitly:

```text
# /etc/portage/package.accept_keywords/volatoo
=sys-apps/volatoo-persist-9999 **
=sys-kernel/volatoo-initramfs-9999 **
```

Install either component with Portage:

```sh
emerge --ask =sys-apps/volatoo-persist-9999
emerge --ask =sys-kernel/volatoo-initramfs-9999
```

## Volatoo development profile

The optional `default/linux/amd64/23.0` profile inherits Gentoo's matching
OpenRC profile and enables the package features required by the Volatoo boot
and persistence design. It is a development profile and is not intended for
general Gentoo systems. The live packages remain explicit installs until a
keyworded release is available.

After adding the repository, find and select it with:

```sh
eselect profile list
eselect profile set PROFILE_NUMBER
```

## Development

Run repository QA from a Gentoo environment:

```sh
pkgcheck scan
```

The repository uses thin manifests and inherits the main Gentoo repository.
