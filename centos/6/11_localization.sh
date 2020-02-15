#!/bin/bash -ux

language="${LANGUAGE:-}"
keyboard="${KEYBOARD:-}"
timezone="${TIMEZONE:-}"

: "SetUp system LANG=${language}" && {

  if [ -n "${language}" -a "${language}" != "en_US.UTF-8" ]
  then

    i18nconf="/etc/sysconfig/i18n"
    yum_conf="/etc/yum.conf"

    [ -e "${i18nconf}" ] || {
      echo 'LANG=""' 1>>"${i18nconf}"
    }

    . "${i18nconf}" || exit 1

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

      if egrep '^LANG=' "${i18nconf}" 1>/dev/null 2>&1
      then
        sed -ri 's/^LANG=.*$/LANG='"${language}"'/g' "${i18nconf}"
      else
        echo 'LANG="'"${language}"'"' 1>>"${i18nconf}"
      fi && {
        echo
        echo "[${i18nconf}]"
        cat "${i18nconf}" || :
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

    kbd_conf="/etc/sysconfig/keyboard"

    [ -s "${kbd_conf}" ] || {
      : && {
cat <<_EOF_
KEYBOARDTYPE="pc"
LAYOUT=""
KEYTABLE=""
MODEL=""
_EOF_
      } 1>"${kbd_conf}"
    }
      
    . "${kbd_conf}" || exit 1

    if [ "${keyboard}" != "${LAYOUT:-}" ]
    then

      if egrep '^LAYOUT=' "${kbd_conf}" 1>/dev/null 2>&1
      then
        sed -ri 's/^LAYOUT=.*$/LAYOUT="'"${keyboard}"'"/g' "${kbd_conf}"
      else
        echo 'LAYOUT="'"${keyboard}"'"' 1>>"${kbd_conf}"
      fi || exit $?

    else :
    fi &&
    if [ "${keyboard}" != "${KEYTABLE:-}" ]
    then

      if egrep '^KEYTABLE=' "${kbd_conf}" 1>/dev/null 2>&1
      then
        sed -ri 's/^KEYTABLE=.*$/LAYOUT="'"${keyboard}"'"/g' "${kbd_conf}"
      else
        echo 'KEYTABLE="'"${keyboard}"'"' 1>>"${kbd_conf}"
      fi || exit $?

    else :
    fi && {
      echo
      echo "[${kbd_conf}]"
      cat "${kbd_conf}" || :
      echo
    }

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
