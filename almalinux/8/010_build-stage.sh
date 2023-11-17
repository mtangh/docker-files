#!/bin/bash -ux
# Script to build a stage

work_dir=$(pwd)

: "Export Args." && {

  export ALMALINUX_VER
  export LANGUAGE TIMEZONE KEYBOARD KBDTABLE
  export ROOTPSWD
  export DOCKERUSER DOCKERPSWD
  export DOCKER_UID DOCKER_GRP DOCKER_GID
  export DOCKER_ACCOUNTNAME DOCKER_GROUPS_LIST
  export DOCKER_USERHOMEDIR DOCKER_LOGIN_SHELL
  export DOCKER_ENABLE_SUDO

};

: "Execute Build Script." && {

  for build_sh in ${scrptdir:-.}/[0-9][0-9][0-9]_*.sh
  do 
    /bin/bash -ux "${build_sh}" || exit 1
  done

} &&
: "DNF Cleanup." && {

  dnf -v -y clean all || :;

  [ -d "/var/cache/dnf/" ] &&
  rm -rf /var/cache/dnf/* || :;

} &&
: "Cleanup." && {

  cd /

  [ -d "/var/log" ] &&
  for lf in /var/log/*
  do
    [ -f "${lf}" -a -s "${lf}" ] &&
    : >"${lf}"
  done || :

  rm -rf {,/var}/tmp/* "${work_dir:-X}" || :; \

} &&
: "Done."

exit $?
 