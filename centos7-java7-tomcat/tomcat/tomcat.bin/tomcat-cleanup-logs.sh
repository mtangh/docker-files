#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

. /etc/sysconfig/tomcat 2>/dev/null || exit 127

function usage() {
  cat <<__EOF__
Usage: $THIS arch_days delete_days
        arch_days >= 3
        delete_days >= 7
__EOF__
  exit 1
}

# check options
[ -n "$1" ] ||
  usage
expr "$1" + 0 1>/dev/null 2>&1 ||
  usage
expr "$2" + 0 1>/dev/null 2>&1 ||
  usage
[ $1 -ge 3 ] ||
  usage
[ $2 -ge 7 ] ||
  usage

# days
arch_days="$1"
delete_days="$2"

# shell flags
set -u

# cleanup old logs
(
  cd "$TOMCAT_HOME/var/log" &&
  for log_file in $(\
    find "$TOMCAT_HOME/var/log" -type f -a ! -name "*.gz" -a -mtime +${arch_days}; )
  do
    fd_no_found=1
    for pid in $(cat $TOMCAT_HOME/var/run/*/*.pid|sort -u) 
    do
      [ -e "/proc/${pid}/fd/" ] &&
        continue
      ls -l "/proc/${pid}/fd/" |
      grep -E ' '"$log_file"'$' 1>/dev/null 2>&1 ||
        continue
      fd_no_found=0
      break
    done
    [ $fd_no_found -eq 1 ] && {
      gzip "$log_file"
    }
  done
) 2>/dev/null

# remove old logs
(
  cd "$TOMCAT_HOME/var/log" &&
  find "$TOMCAT_HOME/var/log" -type f -a -name "*.gz" -a -mtime +${delete_days} -exec rm -f {} \;
) 2>/dev/null

# end of script
exit 0
