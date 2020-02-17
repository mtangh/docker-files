#!/bin/bash -ux

: "Install upstart" && {

  yum -v -y update &&
  yum -v -y install initscripts MAKEDEV sudo && {
    yum -v -y clean all &&
    rm -rf /var/cache/yum/* || :
  }

} &&
: "Change upstart's scripts" && {

  sed -ri 's/^/#/g' /etc/init/tty.conf &&
  sed -ri 's/wn -r now/wn -h now/g' /etc/init/control-alt-delete.conf || :

} &&
: "Rebuild RPM DB" && {

  rpm -e --nodeps kernel kernel-firmware redhat-logos
  rpm --rebuilddb

} &&
: "Disable services" && {

  for _service in iptables netfs udev-post
  do
    chkconfig "${_service}" off
  done

} &&
[ $? -eq 0 ]

exit $?
