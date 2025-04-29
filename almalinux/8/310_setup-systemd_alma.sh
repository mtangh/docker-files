#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

#: "Install systemd" && {
#
#  dnf -v -y update &&
#  dnf -v -y install systemd-container && {
#    dnf -v -y remove \
#      $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) || :
#  } &&
#  dnf -v -y clean all && {
#    rm -rf /var/cache/dnf/* || :
#  }
#
#} &&
: "Remove systemd files" && {

  etc_sysd_dir="/etc/systemd/system"
  lib_sysd_dir="/lib/systemd/system"

  ( cd "${etc_sysd_dir}" && {
      #rm -fv ./*.wants/* || :
      :
    }; )

  ( cd "${lib_sysd_dir}/" && {
      ##rm -frv \
      ##  sockets.target.wants/dbus.socket \
      ##  || :
      #rm -frv \
      #  anaconda.target.wants/* \
      #  basic.target.wants/* \
      #  local-fs.target.wants/* \
      #  multi-user.target.wants/* \
      #  sockets.target.wants/*initctl* \
      #  sockets.target.wants/*udev* \
      #  || :
      rm -frv \
        anaconda.target.wants/* \
        basic.target.wants/* \
        local-fs.target.wants/* \
        initrd.target.wants/ \
        system-update.target.wants/ \
        || :
    } &&
    cd ./sysinit.target.wants && {
      #for f in ./*
      #do
      #  [[ "${f}" =~ /systemd-tmpfiles-setup.*service$ ]] ||
      #  rm -fv "${f}" || :
      #done
      :
    } &&
    : "Done."; )

} &&
[ $? -eq 0 ]

exit $?
