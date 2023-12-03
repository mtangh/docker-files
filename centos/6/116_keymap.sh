#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

keyboard="${KEYBOARD:-}"
kbdtable="${KBDTABLE:-}"

if [ -n "${keyboard}" ]
then
  echo "${keyboard}" |egrep '^[a-z]{2}$' || {
    keyboard=""
  }
fi 1>/dev/null 2>&1

[ -n "${keyboard}${kbdtable}" ] ||
  exit 0

: "SetUp Keyboard: keyboard=${keyboard} kbdtable=${kbdtable}" && {

  kbd_conf="/etc/sysconfig/keyboard"

  [ -s "${kbd_conf}" ] || {
    : && {
cat <<_EOD_
KEYBOARDTYPE="pc"
LAYOUT=""
KEYTABLE=""
MODEL=""
_EOD_
    } 1>"${kbd_conf}"
  }

  . "${kbd_conf}" || exit 1

  if [ "${keyboard}" != "${LAYOUT:-}" ]
  then

    if egrep '^LAYOUT=' "${kbd_conf}" 1>/dev/null 2>&1
    then sed -ri 's/^LAYOUT=.*$/LAYOUT="'"${keyboard}"'"/g' "${kbd_conf}"
    else echo 'LAYOUT="'"${keyboard}"'"' 1>>"${kbd_conf}"
    fi || exit $?

  else :
  fi &&
  if [ "${kbdtable}" != "${KEYTABLE:-}" ]
  then

    if egrep '^KEYTABLE=' "${kbd_conf}" 1>/dev/null 2>&1
    then sed -ri 's/^KEYTABLE=.*$/KEYTABLE="'"${kbdtable}"'"/g' "${kbd_conf}"
    else echo 'KEYTABLE="'"${kbdtable}"'"' 1>>"${kbd_conf}"
    fi || exit $?

  else :
  fi && {
    echo
    echo "[${kbd_conf}]"
    cat "${kbd_conf}" || :
    echo
  }

} &&
[ $? -eq 0 ]

exit $?
