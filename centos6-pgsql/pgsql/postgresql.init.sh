#!/bin/bash
# postgresql   This is the init script for starting up the PostgreSQL
#
# chkconfig: - 64 36
# description: Starts and stops the PostgreSQL backend daemon that handles \
#              all database requests.
# processname: postmaster
# pidfile: /var/run/postmaster.pid

# Source function library.
[ -r "/etc/rc.d/init.d/functions" ] &&
  . /etc/rc.d/init.d/functions

# Get config.
[ -r "/etc/sysconfig/postgresql" ] &&
  . /etc/sysconfig/postgresql

# Get function listing for cross-distribution logic.
TYPESET=`typeset -f|grep "declare"`

# Find the name of the script
NAME="${0##*/}"
unset ISBOOT
if [ "${NAME:0:1}" = "S" -o "${NAME:0:1}" = "K" ]
then
  NAME="${NAME:3}"
  ISBOOT=1
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x "/sbin/runuser" ]
then
  SU=runuser
else
  SU=su
fi

# PostgreSQL Super user
PGUSER="${PGUSER:-postgres}"

# directories
PGHOME="${PGHOME:-/opt/postgresql}"
PGROOT="${PGROOT:-/opt/postgresql}"
PGDATA="${PGDATA:-$PGHOME/data}"
PGPORT="${PGPORT:-5432}"

# postgresql commands
POSTMASTER="${PGROOT}/bin/postmaster"
PG_CONTROL="${PGROOT}/bin/pg_ctl"

# log file
PG_LOG="${PG_LOG:-/var/log/$NAME.log}"

# lock file
PGLOCK="${PGLOCK:-/var/lock/subsys/$NAME}"

# PID file
PG_PID="${PG_PID:-/var/run/postmaster.$PGPORT.pid}"

# export environment variables
export PGDATA PGPORT

# Pretty much need it for postmaster.
if [ ! -f "$POSTMASTER" ]
then
  exit 1
fi

# initialize result
script_result=0

##
# functions
##

start() {
  # Make sure startup-time log file is valid
  if [ ! -e "$PG_LOG" ]
  then
    touch "$PG_LOG" &&
    chown "$PGUSER:$PGUSER" "$PG_LOG" &&
    chmod 0660 "$PG_LOG" || exit 1
    if [ -x "/usr/bin/chcon" ]
    then
      /usr/bin/chcon -u system_u -r object_r -t postgresql_log_t "$PG_LOG"
    fi
  fi 1>/dev/null 2>&1
  # Starting PostgreSQL Service
  echo -n $"Starting ${NAME} service: "
  # PG_CTL start
  : && {
    # pg_ctl start
    $SU -l "$PGUSER" -c "$PG_CONTROL start -D '$PGDATA' -o '-p ${PGPORT}' ${PGCTL_START_OPTS:--s -w}" </dev/null &&
    for count in $(seq 1 30 2>/dev/null)
    do
      [ -n "$(pidof -s "$POSTMASTER" 2>/dev/null)" ] && break
      sleep 1
    done
  } 1>>"$PG_LOG" 2>&1
  # The postmaster is running ?
  if [ -f "${PGDATA}/postmaster.pid" ]
  then
    echo_success
    touch "$PGLOCK"
    head -n 1 "${PGDATA}/postmaster.pid" 1>"$PG_PID"
    script_result=0
  else
    echo_failure
    script_result=1
  fi 2>/dev/null
  echo
  # end
  return $script_result
}

stop() {
  # Stopping PostgreSQL Service
  echo -n $"Stopping ${NAME} service: "
  # PG_CTL stop
  : && {
    $SU -l "$PGUSER" -c "$PG_CONTROL stop -D '$PGDATA' ${PGCTL_STOP_OPTS:--s -m fast}" </dev/null
  } 1>>"$PG_LOG" 2>&1
  script_result=$?
  if [ $script_result -eq 0 ]
  then
    echo_success
    trap "rm -f $PG_PID $PGLOCK" EXIT SIGTERM SIGINT SIGQUIT
  else
    echo_failure
  fi
  echo
  # end
  return  $script_result
}

status() {
  # psotmaster pid
  postmaster_pid="$(/usr/bin/pgrep $POSTMASTER |head -n 1)"
  # The postmaster is running ?
  if [ -n "$postmaster_pid" ]
  then
    echo $"${NAME} (pid $postmaster_pid) is running..."
    script_result=0
  else
    echo $"${NAME} is stopped"
    script_result=3
  fi
  # end
  return $script_result
}

restart() {
  stop
  start
}

condstart() {
  if [ ! -e "$PGLOCK" ]
  then
    restart
  fi
}

condstop() {
  if [ -e "$PGLOCK" ]
  then
    stop
  fi
}

condrestart() {
  if [ -e "$PGLOCK" ]
  then
    restart
  else
    start
  fi
}

reload() {
  : && {
    $SU -l "$PGUSER" -c "$PG_CONTROL reload -D '$PGDATA' ${PGCTL_RELOAD_OPTS:--s}" </dev/null
  } 1>/dev/null 2>&1
  # command state
  script_result=$?
  # end
  return $script_result
}

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# See how we were called.
case "$1" in
start|stop|restart|status|reload)
  $1
  ;;
condrestart|condstart|condstop)
  $1
  ;;
*)
  echo $"Usage: $NAME {start|stop|restart|status|condrestart|condstop|reload}"
  script_result=1
  ;;
esac

# End
exit $script_result
