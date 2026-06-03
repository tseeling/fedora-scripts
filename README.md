# fedora-scripts
Collection of useful scripts for Fedora maintenance

## fc-update.sh

This script will update a mixed environment where Fedora coexists with Linux from Scratch,
and `grub.cfg` is under control of LFS, not Fedora. It contains code to update the kernel and initramfs versions.

## upgrade-f44.sh

This script will upgrade a bunch of machines to the next Fedora version.
It tries to minimize downloads by loading and storing the upgrade file from and to a NAS before the actual upgrade.
TBD: eliminate duplicates if there are new package releases between upgrading multiple machines.
