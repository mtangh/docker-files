#!/bin/bash -ux

: "Install systemd" && {

  yum -v -y update &&
  yum -v -y install systemd-sysv sudo && {
    yum -v -y clean all &&
    rm -rf /var/cache/yum/* || :
  }

} &&
: "Remove systemd files" && {

  etc_sysd_dir="/etc/systemd/system"
  lib_sysd_dir="lib/systemd/system"

  ( cd "${etc_sysd_dir}" && {
      rm -fv ./*.wants/* || :
    }; )

  ( cd "${lib_sysd_dir}/" && {
      #rm -frv \
      #  sockets.target.wants/dbus.socket \
      #  || :
      rm -frv \
        anaconda.target.wants/* \
        basic.target.wants/* \
        local-fs.target.wants/* \
        multi-user.target.wants/* \
        sockets.target.wants/*initctl* \
        sockets.target.wants/*udev* \
        || :
    } &&
    cd ./sysinit.target.wants && {
      for f in ./*
      do
        [[ "${f}" ~= '^systemd-tmpfiles-setup.*service$' ]] ||
        rm -fv "${f}" || :
      done
    } &&
    : "Done."; )

} &&
[ $? -eq 0 ]

exit $?
