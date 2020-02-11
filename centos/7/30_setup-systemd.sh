#!/bin/bash -ux
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

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

  ( cd "${etc_sysd_dir}" && {
      rm -fv ./*.wants/* || :
    }; )

  ( cd "${usr_sysd_dir}/" && {
      rm -fv ${remove_files}
    }
    cd "${usr_sysd_dir}"/sysinit.target.wants && {
      for systemd_file in *
      do
        echo "${systemd_file}" |
        egrep '^systemd-tmpfiles-setup.*service' &>/dev/null ||
        rm -fv "${systemd_file}"
      done
    }
    echo; )

} &&
[ $? -eq 0 ]

exit $?
