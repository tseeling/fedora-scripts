#!/bin/sh

dont=""
while getopts "n" opt
do
	case "${opt}" in
	n) dont=": ";;
	esac
done
shift $(( OPTIND - 1 ))

sudo=
if [[ "$(id -nu)" != "root" ]]
then
	sudo=/usr/bin/sudo
fi

LANG=C
CFG=/boot/grub/grub.cfg
#export DNF_VAR_releasever="${VERSION_ID}"
export LANG

. /etc/profile.d/proxy.sh
. /etc/os-release
MACHID="$( cat /etc/machine-id )"

cpif() {
	${sudo} test -f "${1}" && ${sudo} cp "${1}" "${2}"
}

sedgrub() {
	test -f "${1}${CFG}" || return
	echo "# fixing grub.cfg"
	${sudo} \
	sed -i.old \
	    -e 's/menuentry "Fedora .*/menuentry "Fedora '"${VERSION_ID} ${V%.vanilla*}"'" {/' \
	    -e 's/echo "Loading Fedora '"${VERSION_ID}"' [0-9].*/echo "Loading Fedora '"${VERSION_ID} ${V%.vanilla*}"'"/' \
	    -e 's/echo "Loading Fedora '"${VERSION_ID}"' initramfs .*/echo "Loading Fedora '"${VERSION_ID} initramfs ${V%.vanilla*}"'"/' \
	    -e 's/vmlinuz-.*\.vanilla[^ ]*/vmlinuz-'"${V}"'/' \
	    -e 's/initramfs-.*\.vanilla[^ ]*/initramfs-'"${V}"'.img/' \
	    "${1}${CFG}"
	grep 'menuentry "Fedora "' "${1}${CFG}"
}

test -L /usr/lib/libzstd.so.1 && rm -f /usr/lib/libzstd.so.1
${dont} ${sudo} /usr/bin/dnf -y update --refresh
${dont} ${sudo} /usr/bin/dnf -y upgrade
${dont} ${sudo} /usr/bin/dnf -y autoremove
#${dont} ${sudo} /usr/local/sbin/fc-icons.sh

if ${sudo} test -d /boot/${MACHID}
then
	V="$(${sudo} ls -1v /boot/${MACHID} | tail -1)"
	cpif /boot/${MACHID}/${V}/linux /boot/vmlinuz-${V}
	cpif /boot/${MACHID}/${V}/initrd /boot/initramfs-${V}.img
elif ${sudo} test -d /boot/efi/${MACHID}
then
	V="$(${sudo} ls -1v /boot/efi/${MACHID} | tail -1)"
	cpif /boot/efi/${MACHID}/${V}/linux /boot/vmlinuz-${V}
	cpif /boot/efi/${MACHID}/${V}/initrd /boot/initramfs-${V}.img
else
	V="$(${sudo} ls -1v /boot/loader/entries/ | perl -ne '$v=$1 if (/-(\d+\.\d+\.\d+-\d+\..*)\.conf/); END{print$v}')"
fi
#if [[ -n "${V}" && -f /lib/modules/${V}/vmlinuz ]]
#then
#	${sudo} dracut -f -H /boot/initramfs-${V}.img
#	${sudo} cp -v /lib/modules/${V}/vmlinuz /boot/vmlinuz-${V}
#fi
echo "Fedora ${VERSION_ID} $(/usr/bin/uname -sn) ${V}" | ${sudo} /usr/bin/tee /etc/motd

case "$(hostname)" in
i7|i7.*)
	for devmnt in p3:1 p4:2
	do
		dev=${devmnt%:*}
		mnt=${devmnt#*:}
		mountpoint -q /mnt/lfs${mnt} || ${sudo} mount /mnt/lfs${mnt}
	done
	sedgrub
;;
esac

