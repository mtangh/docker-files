#!/bin/bash -x
# Centos7 Minimal

# /dev files
[ -e "/dev/null" ] || mknod -m 666 /dev/null c 1 3
[ -e "/dev/zero" ] || mknod -m 666 /dev/zero c 1 5
[ -e "/dev/random" ] || mknod -m 666 /dev/random c 1 8
[ -e "/dev/urandom" ] || mknod -m 666 /dev/urandom c 1 9

#  Don't add the anaconda build logs to the image
touch /tmp/NOSAVE_LOGS

# Package setup
rpm --rebuilddb &&
yum -v -y update &&
yum -v -y install \
  bash vim-minimal bind-utils \
  procps-ng tar iputils iproute passwd rootfiles \
  yum-utils yum-plugin-ovl || exit 1

# remove stuff we don't need that anaconda insists on
# kernel needs to be removed by rpm, because of grubby
rpm -e kernel

# Remove
yum -v -y remove \
  bind-libs bind-libs-lite dhclient dhcp-common dhcp-libs \
  dracut-network e2fsprogs e2fsprogs-libs ebtables ethtool file \
  firewalld freetype gettext gettext-libs groff-base grub2 grub2-tools \
  grubby initscripts iproute iptables kexec-tools libcroco libgomp \
  libmnl libnetfilter_conntrack libnfnetlink libselinux-python lzo \
  libunistring os-prober python-decorator python-slip python-slip-dbus \
  snappy sysvinit-tools which linux-firmware GeoIP firewalld-filesystem \
  qemu-guest-agent

# yum cleanup
yum -v -y clean all
rm -rf /var/cache/yum/*

# yum vars
echo "container" >/etc/yum/vars/infra

# Randomize root password and lock
dd if=/dev/urandom count=50 2>/dev/null |md5sum |passwd --stdin root
passwd -l root

##Setup locale properly
#localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

# Fix /run/lock breakage since it\'s not tmpfs in docker
umount /run
systemd-tmpfiles --create --boot

# Remove some things we don't need
rm -rf /tmp/ks-script*
rm -rf /etc/sysconfig/network-scripts/ifcfg-*
rm -rf /usr/lib/locale/locale-archive
rm -rf /etc/udev/hwdb.bin
rm -rf /usr/lib/udev/hwdb.d/*
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

# Make sure login works
rm -f /var/run/nologin

# Generate installtime file record
/bin/date +%Y%m%d_%H%M > /etc/BUILDTIME

# End
exit 0
