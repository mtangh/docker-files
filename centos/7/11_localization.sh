#!/bin/bash -ux

language="${LANGUAGE:-}"
keyboard="${KEYBOARD:-}"
timezone="${TIMEZONE:-}"

yum_lang="${YUM_LANG:-}"

: "SetUp system LANG=${language}" && {

  if [ -n "${language}" ]
  then

    localecf="/etc/locale.conf"

    [ -e "${localecf}" ] && {
      . "${localecf}"
    } || :

    [ -n "${language}" -a -z "${LANG:-}" ] && {
      echo 'LANG=""' 1>>"${localecf}" &&
      . "${localecf}"
    } || :

    if [ -n "${language}" -a "${language}" != "${LANG:-}" ]
    then

      lc_cntr=$(echo "${language}"|cut -d. -f1)
      lc_cntr="${lc_cntr:-en_US}"

      lc_lang=$(echo "${language}"|cut -d. -f2)
      lc_lang="${lc_lang:-UTF-8}"

      localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}" || :

      localectl set-locale "LANG=${lc_cntr}.${lc_lang}" || {
        sed -ri 's/^LANG=.*$/LANG='"${language}"'/g' "${localecf}"
      } && {
        echo
        echo "[${localecf}]"
        cat "${localecf}" || :
        echo
      }

    else :
    fi || exit 1

  else :
  fi

} &&
: "Yum override install langs: ${yum_lang}" && {

  if [ -n "${yum_lang}" ]
  then

    yum_conf="/etc/yum.conf"

    if [ -e "${yum_conf}" ] &&
       egrep '(^[#[:space:]]+|^)override_install_langs=' "${yum_conf}" 1>/dev/null 2>&1
    then

      cat "${yum_conf}" |
      egrep '(^[#[:space:]]+|^)override_install_langs=' |
      egrep "=${yum_lang}" 1>/dev/null 2>&1 || {
        sed -ri \
          's/(^[#[:space:]]+|^)(override_install_langs=).*$/\2'"${yum_lang}"'/g' \
          "${yum_conf}" || exit 1
      } && {
        echo
        echo "[${yum_conf}]"
        cat "${yum_conf}" || :
        echo
      }

    else :
    fi || exit 1

  else :
  fi

} &&
: "SetUp Keyboard: keyboard=${keyboard}" && {

  if [ -n "${keyboard}" ]
  then

    vconconf="/etc/vconsole.conf"

    [ -e "${vconconf}" ] && {
      . "${vconconf}"
    } || :

    [ -n "${keyboard}" -a -z "${KEYMAP:-}" ] && {
      echo 'KEYMAP=""' 1>>"${vconconf}" &&
      . "${vconconf}"
    } || :

    if [ -n "${keyboard}" -a "${keyboard}" != "${KEYMAP:-}" ]
    then

      localectl set-keymap "${keyboard}" || {
        sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${keyboard}"'"/g' "${vconconf}"
      } && {
        echo
        echo "[${vconconf}]"
        cat "${vconconf}" || :
        echo
      }

      : && {
cat <<_EOF_
# Read and parsed by systemd-localed. It's probably wise not to edit this file
# manually too freely.
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${keyboard}"
EndSection
_EOF_
      } 1>/etc/X11/xorg.conf.d/00-keyboard.conf

    else :
    fi || exit 1

  else :
  fi

} &&
: "SetUp Timezone: timezone=${timezone}" && {

  if [ -n "${timezone}" ]
  then

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

  else :
  fi

} &&
[ $? -eq 0 ]

exit $?
