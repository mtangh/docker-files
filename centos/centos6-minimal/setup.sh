#!/bin/bash -x
# Centos6 Minimal

# /dev files
[ -e "/dev/null" ] || mknod -m 666 /dev/null c 1 3
[ -e "/dev/zero" ] || mknod -m 666 /dev/zero c 1 5
[ -e "/dev/random" ] || mknod -m 666 /dev/random c 1 8
[ -e "/dev/urandom" ] || mknod -m 666 /dev/urandom c 1 9

# Package setup
rpm --rebuilddb &&
yum -v -y update &&
yum -v -y install \
 bash vim-minimal bind-utils shadow-utils findutils \
 iputils iproute passwd rootfiles util-linux-ng \
 yum-plugin-ovl || exit 1

# remove stuff we don't need that anaconda insists on
# kernel needs to be removed by rpm, because of grubby
rpm -e kernel

# Remove packages
yum -v -y remove \
  dhclient dhcp-libs dracut grubby kmod grub2 centos-logos \
  hwdata os-prober gettext* bind-license freetype kmod-libs dracutinstall
yum -v -y remove \
  firewalld dbus-glib dbus-python ebtables \
  gobject-introspection libselinux-python pygobject3-base \
  python-decorator python-slip python-slip-dbus kpartx kernel-firmware \
  device-mapper* e2fsprogs-libs sysvinit-tools kbd-misc libss upstart

# yum cleanup
yum -v -y clean all
rm -rf /var/cache/yum/*

# yum vars
echo "container" >/etc/yum/vars/infra

# Randomize root password and lock
dd if=/dev/urandom count=50 2>/dev/null |md5sum |passwd --stdin root
passwd -l root

# Setup locale properly
localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

# Disable services
for serv in `/sbin/chkconfig|cut -f1`
do
  /sbin/chkconfig "$serv" off
done
# udev-post
mv /etc/rc1.d/S26udev-post /etc/rc1.d/K26udev-post

# Remove some things we don't need
rm -rf /tmp/ks-script*
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
rm -rf /usr/lib/locale/locale-archive
rm -rf /boot/*
rm -rf /etc/firewalld
rm -rf /root/*

# Cleanup all log files
for log in $(find /var/log -type f)
do
  [ -f "$log" ] && cat /dev/null 1>"$log";
done
for log in {,/root,/tmp,/var/tmp}/*.log
do
  rm -f "$log"
done

# Generate installtime file record
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME

# End
exit 0
