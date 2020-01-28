#!/bin/bash -ux

language="${CONTAINER_LANGUAGE:-en_US.UTF-8}"
keyboard="${CONTAINER_KEYBOARD:-jp106}"
timezone="${CONTAINER_TIMEZONE:-Asia/Tokyo}"
rootpswd="${CONTAINER_ROOTPSWD:-}"

: "ONBUILD: SetUp system locale: ${language}" && {

  lc_cntr=$(echo "${language}"|cut -d. -f1)
  lc_cntr="${lc_cntr:-en_US}"

  lc_lang=$(echo "${language}"|cut -d. -f2)
  lc_lang="${lc_lang:-UTF-8}"

  localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}" && {
    localectl set-locale "LANG=${lc_cntr}.${lc_lang}" ||
    echo "LANG=${lc_cntr}.${lc_lang}" 1>/etc/locale.conf
  } || exit 1

  if [ -e "/etc/yum.conf" ] &&
     egrep '^override_install_langs=' /etc/yum.conf 1>/dev/null 2>&1
  then
    cat /etc/yum.conf |
    egrep '^override_install_langs=' |
    egrep -v "=${language}" 1>/dev/null && {
      sed -ri \
        's/^(override_install_langs=).*$/'"${language}"'/g'
        /etc/yum.conf || exit 1
    } || :
  fi 2>/dev/null

} &&
: "ONBUILD: keymap: keyboard=${keyboard}" && {

  vconconf="/etc/vconsole.conf"

  [ -e "${vconconf}" ] && {
    . "${vconconf}"
  } &&
  [ -z "${KEYMAP:-}" ] && {
    echo 'KEYMAP='"${keyboard}" 1>>"${vconconf}" &&
    . "${vconconf}"
  } &&
  if [ "${KEYMAP:-}" != "${keyboard}" ]
  then
    sed -ri \
      's/^KEYMAP=.*$/KEYMAP="'"${keyboard}"'"/g' \
       "${vconconf}"
  fi || exit 1

} &&
: "ONBUILD: timezone: timezone=${timezone}" && {

  zoneinfo="/usr/share/zoneinfo"

  if [ -e "${zoneinfo}/${timezone}" ]
  then
   [ ! -e "/etc/localtime" ] || {
     mv -f /etc/localtime{,.ORIG} || :
   } &&
   ln -sf "${zoneinfo}/${timezone}" /etc/localtime &&
   ls -l /etc/localtime
  fi || exit 1

} &&
: "ONBUILD: Set root password" && {

  if [ -n "${rootpswd:-}" ]
  then
    echo "${rootpswd}" |
    passwd --stdin root &&
    passwd -u root &&
    passwd -S root
  fi || exit 1

} &&
: "ONBUILD: Cleanup" && {

  for log_file in /var/log/*
  do
    [ -s "${log_file}" ] &&
    cat /dev/null >"${log_file}" || :
  done
  rm -rf {,/var}/tmp/* /root/*

  yum -v -y clean all
  rm -rf /var/cache/yum/* || :

} &&
[ $? -eq 0 ]

