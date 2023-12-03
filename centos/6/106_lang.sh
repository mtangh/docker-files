#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

language="${LANGUAGE:-}"

[ -n "${language}" ] ||
  exit 0
[ "${language}" != "en_US.UTF-8" ] ||
  exit 0

: "SetUp system LANG=${language}" && {

  localecf="/etc/sysconfig/i18n"
  yum_conf="/etc/yum.conf"

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

  if egrep '^LANG=' "${localecf}" 1>/dev/null 2>&1
  then
    sed -ri 's/^LANG=.*$/LANG='"${language}"'/g' "${localecf}"
  else
    echo 'LANG="'"${language}"'"' 1>>"${localecf}"
  fi && {
    echo
    echo "[${localecf}]"
    cat "${localecf}" || :
    echo
  } &&
  if [ -e "${yum_conf}" ]
  then
    cat "${yum_conf}" |
    egrep '(^[#[:space:]]+|^)override_install_langs=' |
    egrep "[=,]${language}(,.+$|$)" 1>/dev/null 2>&1 || {
      sed -ri \
      's/(^[#[:space:]]+|^)(override_install_langs=.+)$/\2,'"${language}"'/g' \
      "${yum_conf}" || exit 1
      yum -v -y update &&
      yum -v -y clean all
      rm -rf /var/cache/yum/* || :
    } && {
      echo
      echo "[${yum_conf}]"
      cat "${yum_conf}" || :
      echo
    }
  else :
  fi

} &&
[ $? -eq 0 ]

exit $?
