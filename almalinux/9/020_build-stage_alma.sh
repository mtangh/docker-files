#!/bin/bash
# Script to build a stage
THIS="${BASH_SOURCE}"
NAME="${THIS##*/}"
BASE="${NAME%.*}"
CDIR=$([ -n "${THIS%/*}" ] && cd "${THIS%/*}" &>/dev/null; pwd)

set -ux -o errtrace -o functrace -o pipefail

work_dir="$(pwd)"
scrptdir="${scrptdir:-$work_dir}"

if [ -z "${ALMALINUX_VER:-}" ] &&
   [ -r "/etc/os-release" ]
then
  ALMALINUX_VER=$(
    . /etc/os-release &&
    echo "${VERSION_ID:-}" |awk -F. '{print($1);}' 2>/dev/null; )
fi
[ -n "${ALMALINUX_VER:-}" ] ||
if [ -r "/.onbuild/ALMALINUX_VER" ]
then
  ALMALINUX_VER=$(cat "/.onbuild/ALMALINUX_VER" 2>/dev/null)
elif [ -r "./ALMALINUX_VER" ]
then
  ALMALINUX_VER=$(cat "./ALMALINUX_VER" 2>/dev/null)
fi

: "Export Args." && {

  export ALMALINUX_VER
  export INSTALLEPEL
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
  for build_sh in ${scrptdir:-$work_dir}/[0-9][0-9][0-9]_*.sh
  do
    ${shellcmd} "${build_sh}" || exit 1
  done

} &&
: "DNF Cleanup." && {

  dnf -v -y clean all || :

  [ -d "/var/cache/dnf/" ] &&
  rm -rf /var/cache/dnf/* || :

} &&
: "Cleanup." && {

  cd /

  [ -d "/var/log" ] &&
  for lf in /var/log/*
  do
    [ -f "${lf}" -a -s "${lf}" ] && : 1>"${lf}"
    [ -d "${lf}" ] && rm -f "${lf}"/*
  done || :

  rm -rf /var/cache/dnf/* \
         /var/lib/dnf/repos \
         /var/lib/dnf/modulefailsafe/* \
         /var/lib/dnf/history.* \
         /var/lib/rpm/__db.* || :

  rm -rf {,/var}/tmp/* /tmp/.[A-Za-z]* || :

  rm -rf "${work_dir}" "${scrptdir}" || :

} &&
: "Done."

exit $?
