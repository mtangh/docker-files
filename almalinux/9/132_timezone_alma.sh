#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

timezone="${TIMEZONE:-}"

[ -n "${timezone}" ] ||
  exit 0

: "SetUp Timezone: timezone=${timezone}" && {

  zoneinfo="/usr/share/zoneinfo"

  if [ -n "${timezone}" -a -e "${zoneinfo}/${timezone}" ]
  then

    [ -e "/etc/localtime" ] && {
      mv -f /etc/localtime{,.ORIG}
    } || :

    timedatectl set-timezone Asia/Tokyo || {
      ln -sf "${zoneinfo}/${timezone}" /etc/localtime
    } && {
      ls -l /etc/localtime*
    }

  fi || exit 1

} &&
[ $? -eq 0 ]

exit $?
