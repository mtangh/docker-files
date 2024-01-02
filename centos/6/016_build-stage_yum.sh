#!/bin/bash
# Script to build a stage
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)
scrptdir="${scrptdir:-.}"

[ -n "${CENTOS_VER:-}" ] ||
if [ -r "/.onbuild/CENTOS_VER" ]
then
  CENTOS_VER=$(cat "/.onbuild/CENTOS_VER" 2>/dev/null)
elif [ -r "./CENTOS_VER" ]
then
  CENTOS_VER=$(cat "./CENTOS_VER" 2>/dev/null)
fi

: "Export Args." && {

  export CENTOS_VER
  export LANGUAGE
  export TIMEZONE
  export KEYBOARD
  export KBDTABLE
  export LOGROTATION
  export ENABLE_SUDO
  export ENABLE_SSHD
  export ONBUILD_RPM_PACKAGES
  export ONBUILD_SHELL_SCRIPT

  [ -n "${ROOTPSWD:-}" ] ||
  if [ -r "/run/secrets/ROOTPSWD" ]
  then ROOTPSWD=$(cat /run/secrets/ROOTPSWD 2>/dev/null)
  else ROOTPSWD=""
  fi

  export ROOTPSWD

  [ -n "${DOCKER_USERS:-}" ] ||
  if [ -r "/run/secrets/DOCKER_USERS" ]
  then DOCKER_USERS=$(cat /run/secrets/DOCKER_USERS 2>/dev/null)
  else DOCKER_USERS=""
  fi

  export DOCKER_USERS

}

: "Execute Build Script." && {

  shellcmd=""
  [ -z "${shellcmd}" -a -e "/bin/bash" ] &&
    shellcmd="/bin/bash -ux -o errtrace -o functrace -o pipefail" || :
  [ -z "${shellcmd}" -a -e "/bin/sh" ] &&
    shellcmd="/bin/sh" || :

  [ -z "${shellcmd}" ] ||
  for build_sh in ${scrptdir:-.}/[0-9][0-9][0-9]_*.sh
  do 
    ${shellcmd} "${build_sh}" || exit 1
  done

} &&
: "YUM Cleanup." && {

  yum -v -y clean all || :

  [ -d "/var/cache/yum/" ] &&
  rm -rf /var/cache/yum/* || :

} &&
: "Cleanup." && {

  cd /

  [ -d "/var/log" ] &&
  for lf in /var/log/*
  do
    [ -f "${lf}" -a -s "${lf}" ] &&
    : >"${lf}"
  done || :

  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :

  if [ -d "${scrptdir}" ]
  then
    rm -rf "${scrptdir}" || :
  fi

} &&
: "Done."

exit $?
 