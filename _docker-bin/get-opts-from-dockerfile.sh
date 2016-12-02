#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# variables
_dockerf=""
_exports=""

# Options
while [ $# -gt 0 ]
do
  case "$1" in
  -E|--export)
    _exports="export "
    ;;
  -*)
    ;;
  *)
    _dockerf="$1"
    ;;
  esac
  shift
done

# Dockerfile
[ -r "${_dockerf}" ] && {

  SED=""
  [ -z "$SED" -a -n "$(type -P gsed)" ] &&
  SED="$(type -P gsed)"
  [ -z "$SED" -a -n "$(type -P sed)" ] &&
  SED="$(type -P sed)"
  
  cat "${_dockerf}" |
  $SED -ne \
  's;^#@[ ]*\([_A-Za-z][_0-9A-Za-z]*\)[ ]*=[ ]*\(.*\)[ ]*$;\1=\2;gp' \
  2>/dev/null |
  while read variable
  do
    [ -n "$variable" ] &&
    echo $_exports"${variable};"
  done

}

# end
exit $?
