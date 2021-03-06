#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-catalina-cleanup-logs.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# Vars
tcinstances=""
archivedays=""
delete_days=""
verboseflag=0

# Usage
_usage() {
  cat <<__EOF__
Usage: $THIS arch_days delete_days
        arch_days >= 3
        delete_days >= 7
__EOF__
  exit 1
}

# Verbose
_verbose() {
  if [ -n "$@" ]
  then
    [ $verboseflag -gt 0 ] && echo "DEBUG: $@"; :
  else
    [ $verboseflag -gt 0 ]
  fi
  return $?
}

# Parsing options
while [ $# -gt 0 ]
do
  case "$1" in
  -v*|--verbose*)
    verboseflag=1
    ;;
  -*)
    ;;
  *)
    if [ -z "$archivedays" ]
    then
      expr "$1" + 1 &&
      archivedays="$1"
    elif [ -z "$delete_days" ]
    then
      expr "$1" + 1 &&
      delete_days="$1"
    fi 1>/dev/null 2>&1
    ;;
  esac
  shift
done

# Load the catalina.rc
[ -r "${CDIR}/catalina.rc" ] || {
  echo "$THIS: ERROR: 'catalina.rc' is not set." 1>&2
  exit 127
}
. "${CDIR}/catalina.rc" 1>/dev/null || {
  exit $?
}
[ -d "${TOMCAT_HOME}/var/log" ] || {
  echo "$THIS: ERROR: '${TOMCAT_HOME}/var/log' is not a directory." 1>&2
  exit 97
}

# Set the shell flags
set -u

# Tomcat instance pids
tcinstances=$(
  cat ${TOMCAT_HOME}/var/run/*/*.pid 2>/dev/null |
  sort -u)

# default
archivedays="${archivedays:-3}"
delete_days="${delete_days:-7}"

# check options
[ $archivedays -ge 3 ] || _usage
[ $delete_days -ge 7 ] || _usage

# main
cd "${TOMCAT_HOME}/var/log" && {

  log_file=""
  tcinstid=""
  proc_dir=""
  fd_found=0

  archivecount=0
  delete_count=0

  cat <<_EOF_
Logs dir: $(pwd)
Tomcat instance PIDs: $tcinstances.
Compressed / deleted: after $archivedays / $delete_days days.
_EOF_

  # Compress old logs
  for log_file in $(
  find "$(pwd)" -type f -a ! -name "*.gz" -a -mtime +${archivedays}; )
  do
    _verbose "Begin: file='$log_file'."
    proc_dir=""
    fd_found=0
    for tcinstid in ${tcinstances:-}
    do
      proc_dir="/proc/${tcinstid}"
      [ -e "${proc_dir}/fd/" ] || {
        _verbose "[${tcinstid}] No such process: '${proc_dir}'."
        continue
      }
      _verbose && {
        _verbose "[${tcinstid}] proc='${proc_dir}'."
        _verbose "[${tcinstid}] opened $(wc -1 ${proc_dir}/fd/) fds in ${proc_dir}."
      }
      ls -l "${proc_dir}/fd/" |
      egrep ' '"$log_file"'$' 1>/dev/null 2>&1 || {
        _verbose "[${tcinstid}] not found: file='$log_file'."
        continue
      }
      fd_found=1
      _verbose "[${tcinstid}] found: file='$log_file' in ${proc_dir}/fd."
      break
    done
    [ $fd_found -eq 0 ] && {
      gzip "$log_file" &&
      arcivecount=$(( $archivecount + 1 )) &&
      _verbose "Gziped: log_file=$log_file."
    }
    verbose "End: file=$log_file."
  done

  # Remove old logs
  for log_file in $(
  find "$(pwd)" -type f -a -name "*.gz" -a -mtime +${delete_days}; )
  do
    [ -e "$log_file" ] && {
      rm -f "$log_file" &&
      delete_count=$(( $delete_count + 1 )) &&
      _verbose "Remove file: '$log_file'."
    }
  done

  echo "Compressed / deleted: $archivecount / $delete_count files."

} 2>/dev/null |
$AWK '{printf("%s: %s\n","'"${BASE}"'",$0);fflush();};' |
$SED -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g'

# end of script
exit 0
