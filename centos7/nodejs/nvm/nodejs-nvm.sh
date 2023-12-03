#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)

[ -n "${NODEJS_VER:-}" ] || {
  echo "'NODEJS_VER' is not set." 1>&2
  exit 1; }
[ -n "${NVM_DIR:-}" ] || {
  echo "'NVM_DIR' is not set." 1>&2
  exit 1; }

: "SetUp Nodebrew." && {

  [ -n "${NVM_URL:-}" ] &&
  nvm_url="${NVM_URL}" ||
  nvm_url="https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh"

  export NVM_DIR

  [ -d "${NVM_DIR}" ] || mkdir -p "${NVM_DIR}" || :

  curl -sL "${nvm_url}" |/bin/bash && {
    [ -s "${NVM_DIR}/nvm.sh" ] && . "${NVM_DIR}/nvm.sh"
  } &&
  nvm install "${NODEJS_VER}"

} &&
: "SetUp 'node_modules'." && {
 
  /bin/bash -ux -o errtrace -o functrace -o pipefail ./nodejs-node_modules.sh

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
