#!/bin/bash -e

source /etc/os-release
me=${VERSION_ID}
(( me=me+1 ))

dont=
me="${1:-${me}}"

arch=$(uname -m)

me="${me:-45}"
nasdir="/nas/nas1/image/linux/Fedora/f${me}"
nasdirpkg="${nasdir}/packages"
varoff=/var/lib/dnf/offline
vardnf=${varoff}/packages

echo "# upgrade to Fedora ${me}"
journalctl --vacuum-time 4h

${dont} dnf -y clean all
${dont} dnf -y upgrade --refresh
${dont} dnf -y install dnf-plugin-system-upgrade

ssh root@nas mkdir -p "${nasdirdnf}"
echo "# get cache files from ${nasdir}"
rsync -rva root@nas:"${nasdirpkg}" "${varoff}"

${dont} dnf -y system-upgrade download --refresh --releasever="${me}"
${dont} rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-"${me}"-primary

scp /etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-"${me}"-primary root@nas:"${nasdir}"
rsync -rva "${vardnf}" root@nas:"${nasdir}"

echo dnf5 -y offline reboot
