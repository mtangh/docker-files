#!/bin/bash -ux
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

: "Install RPM packages" && {

  packages="${RPM_PACKAGES:-}"

  if [ -z "${packages}" -a -s "./packages.txt" ]
  then
    packages=$(eval echo $(cat "./packages.txt"))
  fi || :

  if [ -n "${packages}" ]
  then

    yum -v -y update &&
    yum -v -y install ${packages}

  else :
  fi || exit 1

  [ -n "${packages}" ] && {
    yum -v -y clean all;
    rm -rf /var/cache/yum/*
  } || :

} &&
[ $? -eq 0 ]

exit $?
