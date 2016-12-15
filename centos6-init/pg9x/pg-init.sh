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
PGDATA="${PGDATA:-$PGHOME/data}"
PGPORT="${PGPORT:-5432}"

# postgresql commands
POSTMASTER="${PGHOME}/bin/postmaster"
PG_CONTROL="${PGHOME}/bin/pg_ctl"

# log file
PG_LOG="${PG_LOG:-/var/log/postgresql.log}"

# lock file
LOCKDILE="/var/lock/subsys/${NAME}"

# PID file
PID_FILE="/var/run/postmaster.${PGPORT}.pid"

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
  if [ ! -e "$PG_LOG" -a ! -h "$PG_LOG" ]
  then
    touch "$PG_LOG" || exit 1
    chown "$PGUSER:$PGUSER" "$PG_LOG"
    chmod 0660 "$PG_LOG"
    if [ -x /usr/bin/chcon ]
    then
      /usr/bin/chcon -u system_u -r object_r -t postgresql_log_t "$PG_LOG" 2>/dev/null
    fi
  fi 1>/dev/null 2>&1

  echo -n $"Starting ${NAME} service: "
  $SU -l "$PGUSER" -c "$POSTMASTER -p '$PGPORT' -D '$PGDATA' ${PGOPTS} &" 1>>"$PG_LOG" 2>&1 </dev/null
  for count in 1 2 3 4 5 6 7 8
  do
    postmaster_pid=$(pidof -s "$POSTMASTER" 2>/dev/null)
    [ -n "$postmaster_pid" ] && break
    sleep 1
  done
  if [ -n "$postmaster_pid" ] &&
     [ -f "${PGDATA}/postmaster.pid" ]
  then
    echo_success
    touch "$LOCKFILE" 1>/dev/null 2>&1
    head -n 1 "${PGDATA}/postmaster.pid" 1>"$PID_FILE" 2>&1
    script_result=0
  else
    echo_failure
    script_result=1
  fi
  echo
  
  return $script_result
}

stop() {

  # Stopping PostgreSQL Service
  echo -n $"Stopping ${NAME} service: "
  $SU -l "$PGUSER" -c "$PG_CONTROL stop -D '$PGDATA' -s -m fast" 1>>"$PG_LOG" 2>&1 </dev/null
  script_result=$?
  if [ $script_result -eq 0 ]
  then
    echo_success
  else
    echo_failure
  fi
  echo
  trap "rm -f $PID_FILE $LOCKFILE" EXIT SIGTERM SIGINT SIGQUIT

  return  $script_result
}

status() {
  status postmaster
  script_result=$?
  return $script_result
}

restart() {
  stop
  start
}

condstart() {
  if [ ! -e "$LOCKFILE" ]
  then
    restart
  fi
}

condstop() {
  if [ -e "$LOCKFILE" ]
  then
    stop
  fi
}

condrestart() {
  if [ -e "$LOCKFILE" ]
  then
    restart
  else
    start
  fi
}

reload() {
  $SU -l "$PGUSER" -c "$PG_CONTROL reload -D '$PGDATA' -s" 1>/dev/null 2>&1 </dev/null
  script_result=$?
}

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# See how we were called.
case "$1" in
start|stop|restart|status|reload)
  $1
  ;;
condrestart|condstarr|condstop)
  $1
  ;;
*)
  echo $"Usage: $NAME {start|stop|restart|status|condrestart|condstop|reload}"
  script_result=1
  ;;
esac

exit $script_result
