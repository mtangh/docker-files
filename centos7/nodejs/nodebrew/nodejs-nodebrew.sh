#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)

[ -n "${NODEJS_VER:-}" ] || {
  echo "'NODEJS_VER' is not set." 1>&2
  exit 1; }
[ -n "${NODEBREW_ROOT:-}" ] || {
  echo "'NODEBREW_ROOT' is not set." 1>&2
  exit 1; }

: "Install packages for nodejs." && {

  yum -v -y update &&
  yum -v -y install gcc-c++ perl which &&
  yum -v -y clean all

} &&
: "SetUp Nodebrew." && {

  [ -n "${NODEBREW_URL:-}" ] &&
  nodebrew_url="${NODEBREW_URL}" ||
  nodebrew_url="http://git.io/nodebrew"

  export NODEBREW_ROOT
  export PATH="${PATH}:${NODEBREW_ROOT}/current/bin"

  curl -sL "${nodebrew_url}" |perl - setup &&
  nodebrew install-binary "${NODEJS_VER}" &&
  nodebrew use "${NODEJS_VER}" &&
  for item in "${NODEBREW_ROOT}/current/"{bin,lib}/*
  do
    dest="/usr/local/${item##*${NODEBREW_ROOT}/current/}"
    [ -x "${item}" ] || continue
    [ ! -d "${dest%/*}" ] && mkdir -p "${dest%/*}" || :
    [ -d "${dest}" ] && rm -rf "${dest}" || :
    ln -sf "${item}" "${dest}" || :
  done

  [ -d "${NODEBREW_ROOT}/" ] && {
    chown -R "root:root" "${NODEBREW_ROOT}/"
  } || :

} &&
: "SetUp 'node_modules'." && {
 
  /bin/bash -ux -o errtrace -o functrace -o pipefail ./nodejs-node_modules.sh

} &&
: "Uninstall unnecessary packages" && {

  yum -v -y remove gcc-c++ && {
    yum -v -y remove $(echo $(package-cleanup --leaves)) || :
  }

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

} &&
: "Done."

exit $?
