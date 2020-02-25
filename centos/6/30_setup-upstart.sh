#!/bin/bash -ux

: "Install upstart" && {

  yum -v -y update &&
  yum -v -y install initscripts MAKEDEV sudo &&
  yum -v -y remove $(echo $(package-cleanup --leaves)) &&
  yum -v -y clean all && {
    rm -rf /var/cache/yum/* || :
  }

} &&
: "Change upstart's scripts" && {

  sed -ri 's/^/#/g' /etc/init/tty.conf &&
  sed -ri 's/wn -r now/wn -h now/g' /etc/init/control-alt-delete.conf || :

} &&
: "Rebuild RPM DB" && {

  rpm -e --nodeps kernel
  rpm -e --nodeps kernel-firmware
  rpm --rebuilddb

} &&
: "Remove 'redhat-logos' files" && {

  # Truncate "redhat-logs" files
  for clf in $(rpm -ql redhat-logos|egrep '[.](jpg|png|svg|tif)$'|sort)
  do
    [ -f "${clf}" ] &&
    cat /dev/null >"${clf}" || :
  done

} &&
: "Disable services" && {

  for _service in iptables netfs udev-post
  do
    chkconfig "${_service}" off
  done

} &&
[ $? -eq 0 ]

exit $?
