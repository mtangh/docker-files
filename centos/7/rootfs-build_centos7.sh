#!/bin/bash -ux
# CentOS7 rootfs build

# /dev files
[ -e "/dev/null" ] || mknod -m 666 /dev/null c 1 3
[ -e "/dev/zero" ] || mknod -m 666 /dev/zero c 1 5
[ -e "/dev/random" ] || mknod -m 666 /dev/random c 1 8
[ -e "/dev/urandom" ] || mknod -m 666 /dev/urandom c 1 9

# Don't add the anaconda build logs to the image
touch /tmp/NOSAVE_LOGS

# Modify yum-fastestmirror
yum_plugins_dir="/etc/yum/pluginconf.d"
yum_mirror_conf="${yum_plugins_dir}/fastestmirror.conf"
[ -e "${yum_mirror_conf}" ] && {
  cat "${yum_mirror_conf}" |
  sed -r \
    -e 's/^verbose=0$/verbose=1/g' \
    -e 's/^(#*)include_only=.*$/include_only=.jp,.org/g' \
    -e '/^include_only=.*$/a prefer=www.ftp.ne.jp' \
    1>"${yum_mirror_conf}.tmp" &&
  mv -f "${yum_mirror_conf}"{.tmp,} &&
  cat "${yum_mirror_conf}"
  [ $? -eq 0 ] || exit 1
} || :

# Package setup
rpm --rebuilddb &&
yum -v -y update &&
yum -v -y install \
  bash \
  bind-utils \
  iputils \
  iproute \
  passwd \
  procps-ng \
  rootfiles \
  tar \
  vim-minimal \
  yum-utils \
  yum-plugin-ovl \
  || exit 1

# Install EPEL
yum -v -y install \
  epel-release \
  || exit 1

# remove stuff we don't need that anaconda insists on
# kernel needs to be removed by rpm, because of grubby
rpm -e kernel || :

# Remove
yum -v -y remove \
  bind-libs \
  bind-libs-lite \
  dhclient \
  dhcp-common \
  dhcp-libs \
  dracut-network \
  e2fsprogs \
  e2fsprogs-libs \
  ebtables \
  ethtool \
  file \
  firewalld \
  firewalld-filesystem \
  freetype \
  gettext \
  gettext-libs \
  GeoIP \
  groff-base \
  grub2 \
  grub2-tools \
  grubby \
  initscripts \
  iproute \
  iptables \
  kexec-tools \
  libcroco \
  libgomp \
  libmnl \
  libnetfilter_conntrack \
  libnfnetlink \
  libselinux-python \
  libunistring \
  linux-firmware \
  lzo \
  os-prober \
  python-decorator \
  python-slip \
  python-slip-dbus \
  qemu-guest-agent \
  snappy \
  sysvinit-tools \
  which \
  || exit 1

# yum cleanup
yum -v -y clean all
rm -rf /var/cache/yum/*

# yum vars
echo "container" 1>/etc/yum/vars/infra

# Randomize root password and lock
dd if=/dev/urandom count=50 |md5sum |
passwd --stdin root &&
passwd -l root &&
passwd -S root || exit 1

##Setup locale properly
#localedef -v -c -i en_US -f UTF-8 en_US.UTF-8

# Fix /run/lock breakage since it's not tmpfs in docker
umount /run
systemd-tmpfiles --create --boot

# Remove some things we don't need
rm -rf \
  /boot/* \
  /etc/firewalld \
  /etc/sysconfig/network-scripts/ifcfg-* \
  /etc/udev/hwdb.bin \
  /usr/lib/locale/locale-archive
  /usr/lib/udev/hwdb.d/* \
  /root/*

# Make sure login works
rm -f /var/run/nologin

# Cleanup all log files
for log_file in /var/log/*
do
  [ -s "${log_file}" ] &&
  cat /dev/null 1>"${log_file}" || :
done

# Cleanup tmp.
rm -f {,/var}/tmp/* /root/*

# Generate installtime file record
/bin/date +'%Y%m%dT%H%M%S' 1>/etc/BUILDTIME || :

# End
exit 0
