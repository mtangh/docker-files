#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

: "Install upstart" && {

  yum -v -y update &&
  yum -v -y install initscripts MAKEDEV &&
  yum -v -y remove $(echo $(package-cleanup --leaves)) &&
  yum -v -y clean all && {
    rm -rf /var/cache/yum/* || :
  }

} &&
: "Change upstart's scripts" && {

  sed -ri 's/^/#/g' \
    /etc/init/tty.conf &&
  sed -ri 's/^/#/g' \
    /etc/init/start-ttys.conf &&
  sed -ri 's/wn -r now/wn -h now/g' \
    /etc/init/control-alt-delete.conf || :

} &&
: "Rebuild RPM DB" && {

  rpm -e --nodeps kernel
  rpm -e --nodeps kernel-firmware
  rpm -e --nodeps redhat-logos
  rpm --rebuilddb

} &&
: "Initialize" && {

  # Touch fstab
  cat /dev/null 1>/etc/fstab

  # Create '/etc/sysconfig/network'
  echo "NETWORKING=yes" 1>/etc/sysconfig/network

  # UDEV Off
  mv -f /sbin/start_udev{,.off} &&
  ln -sf /bin/true /sbin/start_udev || :

} &&
: "Disable services" && {

  for _service in iptables netfs udev-post
  do
    chkconfig "${_service}" off
  done

} &&
[ $? -eq 0 ]

exit $?
