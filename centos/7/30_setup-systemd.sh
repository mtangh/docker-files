#!/bin/bash -ux

: "Install systemd" && {

  yum -v -y update &&
  yum -v -y install systemd-sysv sudo &&
  yum -v -y clean all
  rm -rf /var/cache/yum/*

} &&
: "Remove systemd files" && {

  etc_sysd_dir="/etc/systemd/system"
  usr_sysd_dir="/usr/lib/systemd/system"

  remove_files=$(cat <<_END_
multi-user.target.wants/dbus.service
multi-user.target.wants/getty.target
multi-user.target.wants/systemd-ask-password-wall.path
multi-user.target.wants/systemd-update-utmp-runlevel.service
sockets.target.wants/dbus.socket
sockets.target.wants/systemd-initctl.socket
sockets.target.wants/systemd-udevd-control.socket
sockets.target.wants/systemd-udevd-kernel.socket
sysinit.target.wants/systemd-ask-password-console.path
sysinit.target.wants/systemd-udevd.service
sysinit.target.wants/systemd-udev-trigger.service
sysinit.target.wants/systemd-vconsole-setup.service
local-fs.target.wants/systemd-remount-fs.service
_END_
)

  rm -f "${etc_sysd_dir}"/*.wants/* || :

  ( cd "${usr_sysd_dir}/" && {
      for item in ${remove_files}
      do
        [ -z "${item}" ] || rm -f "${item}"
      done
    } &>/dev/null
    cd ./sysinit.target.wants && {
      for item in *
      do
        echo "${item}" |
        egrep '^systemd-tmpfiles-setup.*service' ||
        rm -f "${item}"
      done
    } &>/dev/null
    echo; )

} &&
[ $? -eq 0 ]

