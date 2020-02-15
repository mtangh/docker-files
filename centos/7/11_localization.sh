#!/bin/bash -ux

language="${LANGUAGE:-}"
keyboard="${KEYBOARD:-}"
timezone="${TIMEZONE:-}"

: "SetUp system LANG=${language}" && {

  if [ -n "${language}" -a "${language}" != "en_US.UTF-8" ]
  then

    localecf="/etc/locale.conf"
    yum_conf="/etc/yum.conf"

    [ -s "${localecf}" ] || {
      echo 'LANG=""' 1>"${localecf}"
    }

    . "${localecf}" || exit 1

    if [ "${language}" != "${LANG:-}" ]
    then

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

    else :
    fi || exit 1

  else :
  fi

} &&
: "SetUp Keyboard: keyboard=${keyboard}" && {

  if [ -n "${keyboard}" ] &&
     egrep '^[a-z]{2}$' 1>/dev/null 2>&1
  then

    vconconf="/etc/vconsole.conf"
    xkbdconf="/etc/X11/xorg.conf.d/00-keyboard.conf"

    [ -s "${vconconf}" ] || {
      echo 'KEYMAP=""' 1>"${vconconf}"
    }

    . "${vconconf}" || exit 1

    if [ "${keyboard}" != "${KEYMAP:-}" ]
    then

      localectl set-keymap "${keyboard}" "${keyboard}" || {

        if egrep '^KEYMAP=' "${vconconf}" 1>/dev/null 2>&1
        then
          sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${keyboard}"'"/g' "${vconconf}"
        else
          echo 'KEYMAP="'"${keyboard}"'"' 1>>"${keyboard}"
        fi && {
          echo
          echo "[${vconconf}]"
          cat "${vconconf}" || :
          echo
        } &&
        if [ -d "${xkbdconf%/*}" ]
        then
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
          } 1>"${xkbdconf}" && {
            echo
            echo "[${xkbdconf}]"
            cat "${xkbdconf}" || :
            echo
          }
        else :
        fi

      } # localectl set-keymap ...

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
