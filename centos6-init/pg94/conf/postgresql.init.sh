#!/bin/sh
# postgresql   This is the init script for starting up the PostgreSQL
#              server For JCI Service System
#
# chkconfig: - 64 36
# description: Starts and stops the PostgreSQL backend daemon that handles \
#              all database requests.
# processname: postmaster
# pidfile: /var/run/postmaster.pid

# Source function library.
. /etc/rc.d/init.d/functions

# Get function listing for cross-distribution logic.
TYPESET=`typeset -f|grep "declare"`

# Get config.
. /etc/sysconfig/network

# Find the name of the script
NAME=`basename $0`
unset ISBOOT
if [ ${NAME:0:1} = "S" -o ${NAME:0:1} = "K" ]; then
  NAME=${NAME:3}
  ISBOOT=1
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x /sbin/runuser ]; then
  SU=runuser
else
  SU=su
fi

# PostgreSQL Super user
PGUSER=postgres

# postgresql commands
POSTMASTER=/opt/postgresql/bin/postmaster
PG_CONTROL=/opt/postgresql/bin/pg_ctl

# directories
PGHOME=/home/postgres
PGROOT=/opt/postgresql
PGDATA=/opt/postgresql/data
PGPORT=5480

# log file
PG_LOG=/var/log/postgresql.log

# export environment variables
export PGDATA
export PGPORT

# Check that networking is up.
if [ "${NETWORKING}" = "no" ]; then
  exit 1
fi

# Pretty much need it for postmaster.
if [ ! -f "$POSTMASTER" ]; then
  exit 1
fi

# initialize result
script_result=0

##
# functions
##

start() {
  PG_INIT_DB=$PGROOT/bin/initdb
  PSQL_START=$"Starting ${NAME} service: "

  # Make sure startup-time log file is valid
  if [ ! -e "$PG_LOG" -a ! -h "$PG_LOG" ]; then
    touch "$PG_LOG" || exit 1
    chown $PGUSER:$PGUSER "$PG_LOG"
    chmod 0660 "$PG_LOG"
    if [ -x /usr/bin/chcon ]; then
      /usr/bin/chcon -u system_u -r object_r -t postgresql_log_t "$PG_LOG" 2>/dev/null
    fi
  fi

  echo -n "$PSQL_START"
  $SU -l $PGUSER -c "$POSTMASTER -p '$PGPORT' -D '$PGDATA' ${PGOPTS} &" >> "$PG_LOG" 2>&1 < /dev/null
  sleep 2
  pid=`pidof -s "$POSTMASTER"`
  if [ $pid ] && [ -f "${PGDATA}/postmaster.pid" ]; then
    success "$PSQL_START"
    touch /var/lock/subsys/${NAME}
    head -n 1 "${PGDATA}/postmaster.pid" > "/var/run/postmaster.${PGPORT}.pid"
    echo
  else
    failure "$PSQL_START"
    echo
    script_result=1
  fi
  
}

stop() {

  # Stopping PostgreSQL Service
  echo -n $"Stopping ${NAME} service: "
  $SU -l $PGUSER -c "$PG_CONTROL stop -D '$PGDATA' -s -m fast" > /dev/null 2>&1 < /dev/null
  ret=$?
  if [ $ret -eq 0 ]; then
    echo_success
  else
    echo_failure
    script_result=1
  fi
  echo
  rm -f "/var/run/postmaster.${PGPORT}.pid"
  rm -f "/var/lock/subsys/${NAME}"

}

status() {
  status postmaster
  script_result=$?
}
allstatus() {
  status postmaster && status slon
  script_result=$?
}

restart() {
  stop
  start
}

condrestart() {
  if [ -e /var/lock/subsys/${NAME} ]; then
    restart
  fi
}
condstop() {
  if [ -e /var/lock/subsys/${NAME} ]; then
    stop
  fi
}
reload() {
  $SU -l $PGUSER -c "$PG_CONTROL reload -D '$PGDATA' -s" > /dev/null 2>&1 < /dev/null
}

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# See how we were called.
case "$1" in
start|stop|status|allstatus|restart|condrestart|condstop|reload)
  $1
  ;;
*)
  echo $"Usage: $NAME {start|stop|status|allstatus|restart|condrestart|condstop|reload}"
  script_result=1
  ;;
esac

exit $script_result
