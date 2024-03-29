# _docker-make-functions.sh
DOCKERMAKEFUNC_SRC="${BASH_SOURCE##*/}"
DOCKERMAKEFUNC_DIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)

# Functions
[ -f "${DOCKERMAKEFUNC_DIR}/functions.sh" ] && {
  . "${DOCKERMAKEFUNC_DIR}/functions.sh"
} || exit 1

# proc start
dmf_proc_start() {
  __section
cat <<'_EOM_'
   ____             _               __  __       _
  |  _ \  ___   ___| | _____ _ __  |  \/  | __ _| | _____
  | | | |/ _ \ / __| |/ / _ \ '__| | |\/| |/ _` | |/ / _ \
  | |_| | (_) | (__|   <  __/ |    | |  | | (_| |   <  __/
  |____/ \___/ \___|_|\_\___|_|    |_|  |_|\__,_|_|\_\___|
_EOM_
  if [ ${1:-0} -eq 0 ]
  then 
    for i in $(seq 1 35);do printf ' ';done;
    echo "WITH RUN."
  else
    echo
  fi
  __section
  return 0;
}

# proc end
dmf_proc_exit() {
  local _exit_st=${1:-$?}
  __section
  if [ ${_exit_st:-0} -eq 0 ]
  then
cat <<'_EOM_'
   _____                   _
  | ____|    _ __       __| |
  |  _|     | '_ \     / _` |
  | |___    | | | |   | (_| |
  |_____|   |_| |_|    \__,_|
  
_EOM_
  else
cat <<'_EOM_'
      _    _                _           _
     / \  | |__   ___  _ __| |_ ___  __| |
    / _ \ | '_ \ / _ \| '__| __/ _ \/ _` |
   / ___ \| |_) | (_) | |  | ||  __/ (_| |
  /_/   \_\_.__/ \___/|_|   \__\___|\__,_|

_EOM_
  fi
  __section
  if [ ${_exit_st:-0} -ne 0 ]
  then exit ${_exit_st:-0}
  else :
  fi
  return ${_exit_st:-0}
}

# invoke
dmf_invoke() {
  local _cmd="${1:-}"; shift
  local _ret=0
  dmf_echo_start "${_cmd}" "$@"
  ${_cmd} "$@"; _ret=$?
  dmf_echo_end ${_ret}
  return ${_ret}
}

# Wait
dmf_wait() {
  local cpid="${1:-$!}"
  [ -z "${cpid}" ] ||
  while :
  do
    ps |${AWK} '{print($1);}' |egrep "${cpid}"
    if [ $? -eq 0 ]
    then sleep 1
    else break
    fi
  done 1>/dev/null 2>&1
  return 0
} &>/dev/null

# echo start
dmf_echo_start() {
  echo "{{{ START - $(date +'%Y%m%dT%H%M%S')"
  [ -n "${1:-}" ] &&
  echo "COMMAND=[$@]"
  return 0
}

# echo end
dmf_echo_end() {
  local _exit_st=${1:-$?}
  if [ ${_exit_st:-0} -eq 0 ]
  then
    echo "}}} END - $(date +'%Y%m%dT%H%M%S')"
  else
    echo "}}} ERROR OCCURED - ret(${_exit_st})."
    echo
	  dmf_proc_exit ${_exit_st}
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
    printf "${_tag:+${_tag}: }"
    for i in $(seq 1 ${_len});do printf '-';done;echo
  } 2>/dev/null
  return 0
}
# Section
dmf_section() {
  __section "$@" |dmf_stdout_with_ts ""
  return 0
}

# Stdout
dmf_stdout() {
  local _tag="${1:-}"
  ${AWK} -v_tag="${_tag:+${_tag}: }" \
  '{printf("%s%s\n",_tag,$0);fflush();};' #|
# ${SED} -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g'
  return 0
}

# Stdout with TS
dmf_stdout_with_ts() {
  dmf_stdout "$@" |
  ${AWK} '{
  print(strftime("%Y%m%dT%H%M%S",systime())": "$0);
  fflush();};'
  return 0
}

# vim: set ff=unix ts=2 sw=2 sts=2 et : This line is VIM modeline
return 0
