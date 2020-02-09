#!/bin/bash -ux

language="${LANGUAGE:-en_US.UTF-8}"
keyboard="${KBD_TYPE:-jp}"
kmaptype="${KMAPTYPE:-jp106}"
timezone="${TIMEZONE:-Asia/Tokyo}"

yum_lang="${YUM_LANG:-en_US.UTF-8}"

: "ONBUILD: SetUp system locale: ${language}" && {

  localecf="/etc/locale.conf"

  [ -e "${localecf}" ] && {
    . "${localecf}"
  } || :

  [ -z "${LANG:-}" ] && {
    echo 'LANG='"${language}" 1>>"${localecf}" &&
    . "${localecf}"
  } || :

  if [ "${LANG:-}" != "${language}" ]
  then

    lc_cntr=$(echo "${language}"|cut -d. -f1)
    lc_cntr="${lc_cntr:-en_US}"

    lc_lang=$(echo "${language}"|cut -d. -f2)
    lc_lang="${lc_lang:-UTF-8}"

    localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}" || :

    sed -ri 's/^LANG=.*$/LANG='"${language}"'/g' "${localecf}"

  fi &&
  cat "${localecf}" ||
  exit 1

  if [ -e "/etc/yum.conf" ] &&
     egrep '^override_install_langs=' /etc/yum.conf 1>/dev/null 2>&1
  then
    cat /etc/yum.conf |
    egrep '^override_install_langs=' |
    egrep -v "=${yum_lang}" 1>/dev/null && {
      sed -ri \
        's/^(override_install_langs=).*$/\1'"${yum_lang}"'/g'
        /etc/yum.conf || exit 1
    } || :
  fi 2>/dev/null

} &&
: "ONBUILD: keymap: kmaptype=${kmaptype}" && {

# localectl set-keymap "${kmaptype}" ||
# exit 1

  vconconf="/etc/vconsole.conf"

  [ -e "${vconconf}" ] && {
    . "${vconconf}"
  } || :

  [ -z "${KEYMAP:-}" ] && {
    echo 'KEYMAP='"${kmaptype}" 1>>"${vconconf}" &&
    . "${vconconf}"
  } || :

  if [ "${KEYMAP:-}" != "${kmaptype}" ]
  then
    sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${kmaptype}"'"/g' "${vconconf}"
  fi &&
  cat "${vconconf}" ||
  exit 1

} &&
: "ONBUILD: timezone: timezone=${timezone}" && {

# timedatectl set-timezone Asia/Tokyo ||
# exit 1

  zoneinfo="/usr/share/zoneinfo"

  if [ -e "${zoneinfo}/${timezone}" ]
  then

   [ ! -e "/etc/localtime" ] || {
     mv -f /etc/localtime{,.ORIG} || :
   }

   ln -sf "${zoneinfo}/${timezone}" /etc/localtime &&
   ls -l /etc/localtime

  fi || exit 1

} &&
[ $? -eq 0 ]

