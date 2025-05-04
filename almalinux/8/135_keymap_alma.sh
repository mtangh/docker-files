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

  vconconf="/etc/vconsole.conf"
  xkbdconf="/etc/X11/xorg.conf.d/00-keyboard.conf"

  [ -s "${vconconf}" ] || {
    : && {
cat <<_EOD_
KEYMAP="us"
FONT="eurlatgr"
_EOD_
    } 1>"${vconconf}"
  }

  . "${vconconf}" || exit 1

  if [ "${kbdtable}" != "${KEYMAP:-}" ]
  then

    localectl set-keymap "${kbdtable}" "${kbdtable}" || {

      if egrep '^KEYMAP=' "${vconconf}" 1>/dev/null 2>&1
      then sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${kbdtable}"'"/g' "${vconconf}"
      else echo 'KEYMAP="'"${kbdtable}"'"' 1>>"${vconconf}"
      fi && {
        echo
        echo "[${vconconf}]"
        cat "${vconconf}" || :
        echo
      } &&
      if [ -n "${keyboard}" -a -n "${kbdtable}" -a -d "${xkbdconf%/*}" ]
      then
        : && {
cat <<_EOD_
# Read and parsed by systemd-localed. It's probably wise not to edit this file
# manually too freely.
Section "InputClass"
        Identifier "system-keyboard"
        MatchIsKeyboard "on"
        Option "XkbLayout" "${keyboard}"
        Option "XkbModel" "${kbdtable}"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
EndSection
_EOD_
        } 1>"${xkbdconf}" && {
          echo
          echo "[${xkbdconf}]"
          cat "${xkbdconf}" || :
          echo
        }
      else rm -f "${xkbdconf}" || :
      fi

    } # localectl set-keymap ...

  else :
  fi || exit 1

} &&
[ $? -eq 0 ]

exit $?
