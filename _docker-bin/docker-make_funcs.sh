# _docker-make-functions.sh
DOCKERMAKEFUNC_SRC="${BASH_SOURCE##*/}"
DOCKERMAKEFUNC_DIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

# Functions
[ -f "${DOCKERMAKEFUNC_DIR}/functions.sh" ] && {
  . "${DOCKERMAKEFUNC_DIR}/functions.sh"
} || exit 1

# echo start
__echo_start() {
  echo "{{{ START - $(date +'%Y%m%dT%H%M%S')"
  [ -n "${1:-}" ] &&
  echo "COMMAND=[$@]"
  return 0
}

# echo end
__echo_end() {
  local _exit_st=${1:-}
  if [ ${_exit_st} -eq 0 ]
  then
    echo "}}} END - $(date +'%Y%m%dT%H%M%S')"
  else
    echo "}}} ERROR OCCURED - ret(${_exit_st})."
    exit ${_exit_st}
  fi
  return 0
}

# Section
__section() {
  local _tag="${1:-}"; shift
  local _len="${1:-67}"; shift
  : 1>/dev/null 2>&1 && {
    [ -n "${_tag}" ] && {
      _len=$(( $_len - ${#_tag} - 2 ))
    } || :
    printf ""
    for i in $(seq 1 ${_len});do printf '-';done;echo
  } 2>/dev/null
  return 0
}

# Stdout with TS
__stdout_with_ts() {
  local _tag="${1:-}"
  ${AWK} '{
  printf("%s: %s%s\n",
  strftime("%Y%m%dT%H%M%S",systime()),"'"${_tag:+${_tag}: }"'",$0);
  fflush();};' |
  ${SED} -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g'
  return 0
}

# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
return 0
