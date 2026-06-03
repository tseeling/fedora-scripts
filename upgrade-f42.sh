#!/bin/bash -e

dont=
me="${0##*-f}"
me="${me%.sh}"
me="${1:-${me}}"

me="${me:-42}"
nasdir="/nas/nas1/image/linux/Fedora/f${me}"
nasdirdnf="${nasdir}/dnf"

echo "# upgrade to Fedora ${me}"
journalctl --vacuum-time 4h

${dont} dnf -y clean all
${dont} dnf -y upgrade --refresh
${dont} dnf -y install dnf-plugin-system-upgrade

ssh root@nas mkdir -p "${nasdirdnf}"
echo "# get cache files from ${nasdir}"
rsync -rva root@nas:"${nasdirdnf}" /var/lib/

${dont} dnf -y system-upgrade download --refresh --releasever="${me}"
${dont} rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-"${me}"-primary

scp /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-"${me}"-primary root@nas:"${nasdir}"
rsync -rva /var/lib/dnf root@nas:"${nasdir}"

echo dnf5 -y offline reboot
