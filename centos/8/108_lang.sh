#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

language="${LANGUAGE:-}"

[ -n "${language}" ] ||
  exit 0
[ "${language}" != "en_US.UTF-8" ] ||
  exit 0

: "SetUp system LANG=${language}" && {

  localecf="/etc/locale.conf"

  [ -s "${localecf}" ] || {
cat <<_EOD_ 1>"${localecf}"
LANG=
_EOD_
  }

  . "${localecf}" || exit 1

  [ "${language}" != "${LANG:-}" ] ||
    exit 0

  locale=$(echo "${language}"|cut -d. -f1)
  locale="${locale:-en_US}"

  chrmap=$(echo "${language}"|cut -d. -f2)
  chrmap="${chrmap:-UTF-8}"

  locale -a |
  egrep -i "${locale}.${chrmap//-}" || {
    localedef -v -c -i "${locale}" -f "${chrmap}" "${locale}.${chrmap}" || :
  }

  localectl set-locale "LANG=${locale}.${chrmap}" || {
    if egrep '^LANG=' "${localecf}" 1>/dev/null 2>&1
    then
      sed -ri 's/^LANG=.*$/LANG='"${language}"'/g' "${localecf}"
    else
      echo 'LANG="'"${language}"'"' 1>>"${localecf}"
    fi
  } && {
    echo
    echo "[${localecf}]"
    cat "${localecf}" || :
    echo
  } || exit 1

} &&
[ $? -eq 0 ]

exit $?
