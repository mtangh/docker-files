#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

set +x

rootpswd="${ROOTPSWD:-}"
echo "ROOTPSWD=[${roowpswd:+********}]"

: "Set root password" && {

  if [ -n "${rootpswd}" ]
  then

    if [ -x "$(type -P passwd)" ]
    then
      echo "echo '${roowpswd:+********}' |passwd --stdin root" &&
      echo "${rootpswd}" |passwd --stdin root &&
      passwd -u root &&
      passwd -S root
    else
      echo "echo 'root:${roowpswd:+********}' |chpasswd" &&
      echo "root:${rootpswd}" |chpasswd
    fi

  fi || exit 1

} &&
[ $? -eq 0 ]

set -x

exit $?
