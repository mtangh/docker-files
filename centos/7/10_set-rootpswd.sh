#!/bin/bash -ux
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

rootpswd="${ROOTPSWD:-}"

: "Set root password" && {

  if [ -n "${rootpswd}" ]
  then

    echo "${rootpswd}" |
    passwd --stdin root &&
    passwd -u root &&
    passwd -S root

  fi || exit 1

} &&
[ $? -eq 0 ]

exit $?
