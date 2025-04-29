#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

#: "Install systemd" && {
#
#  dnf -v -y update &&
#  dnf -v -y install systemd-container && {
#    dnf -v -y remove --exclude=binutils \
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
      #rm -fv $(ls -1 ./*.wants/* |egrep -v sockets[.]target[.] 2>/dev/null) || :
      :
    }; )

  ( cd "${lib_sysd_dir}/" && {
      #rm -frv \
      #  anaconda.target.wants/* \
      #  basic.target.wants/* \
      #  local-fs.target.wants/* \
      #  sockets.target.wants/*initctl* \
      #  sockets.target.wants/*udev* \
      #  || :
      rm -frv \
        anaconda.target.wants/* \
        basic.target.wants/* \
        local-fs.target.wants/ \
        initrd.target.wants/ \
        system-update.target.wants/ \
        || :
      #[ -d "./multi-user.target.wants" ] &&
      #for f in ./multi-user.target.wants/*
      #do
      #  [[ "${f}" =~ /systemd-user-sessions[.]service$ ]] ||
      #  rm -fv "${f}" || :
      #done
      #[ -d "./sysinit.target.wants" ] &&
      #for f in ./sysinit.target.wants/*
      #do
      #  [[ "${f}" =~ /systemd-tmpfiles-setup.*service$ ]] ||
      #  rm -fv "${f}" || :
      #done
    } &&
    : "Done."; )

} &&
[ $? -eq 0 ]

exit $?
