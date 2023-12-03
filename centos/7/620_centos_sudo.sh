#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

if [ "${ENABLE_SUDO:-YES}" != "YES" ]
then
  echo "Without SUDO, skipping this instruction."
  exit 0
fi

YUM=yum

case "${CENTOS_VER:-X}" in
8*)
  YUM=dnf
  ;;
*)
  ;;
esac

: "sshd: Install sudo" && {

  $YUM -v -y update || :
  $YUM -v -y install sudo

} &&
: "sshd: Configure sudoers" && {

  sudo_config="/etc/sudoers"

  if [ -s "${sudo_config}" ]
  then

    if [ -d "${sudo_config}.d/" ] &&
       [ "$(ls -1 ${sudo_config}.d/ |wc -l 2>/dev/null)" != "0" ] 
    then
      sed -ri 's/^#(includedir[[:space:]]+\/etc\/sudoers[.]d)$/\1/g' "${sudo_config}" &&
      cat "${sudo_config}"
    else : "noop"
    fi

  else : "noop"
  fi

} &&
[ $? -eq 0 ]

exit $?
