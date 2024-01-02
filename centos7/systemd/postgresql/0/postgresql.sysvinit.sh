#!/bin/sh
#
# postgresql    This is the init script for starting up the PostgreSQL
#               server.
#
# chkconfig: - 64 36
# description: PostgreSQL database server.
# processname: postmaster
# pidfile: /var/run/postmaster.PORT.pid

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# Source function library.
funcload=0
if [ -f "/etc/rc.d/init.d/functions" ]
then
  . /etc/rc.d/init.d/functions &&
  funcload=1
else :
fi

# Get network config.
if [ -f "/etc/sysconfig/network" ]
then . /etc/sysconfig/network
else exit 6
fi

# Find the name of the script
NAME="${0##*/}"
if [ "${NAME:0:1}" = "S" -o "${NAME:0:1}" = "K" ]
then
  NAME=${NAME:3}
fi

# For SELinux we need to use 'runuser' not 'su'
if [ -x "/sbin/runuser" ]
then SU=runuser
else SU=su
fi

# Set defaults for configuration variables
PG_BIN="/opt/postgresql/bin"
PGUSER="postgres"
PGPORT="5432"
PGDATA="/opt/postgresql/data"

# Value to set as postmaster process's oom_adj
PG_OOM_ADJ=-17

# Get postgresql config.
. "/etc/sysconfig/${NAME}"
if [ $? -ne -0 ]
then
  echo "${NAME}: ERROR: no such file or directory '/etc/sysconfig/${NAME}'."
  exit 2
fi

# PGVERSION is the full package version, e.g., 8.4.0
# Note: the specfile inserts the correct value during package build
PGVERSION="${PGSQLVER}"
# PGMAJORVERSION is major version, e.g., 8.4 (this should match PG_VERSION)
PGMAJORVERSION=$(echo "${PGVERSION}" |sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' 2>/dev/null)

# Exports
export PGDATA
export PGPORT

# boot log file
boot_log="/var/log/${NAME}-boot.log"

# PID file
pid_file="/var/run/${NAME}.${PGPORT}.pid"

# Script result
_RET=0

# Make sure startup-time log file is valid
if [ ! -e "${boot_log}" -a ! -h "${boot_log}" ]
then
  touch "${boot_log}" || exit 4
  chown "${PGUSER}:${PGUSER}" "${boot_log}" &&
  chmod 0660 "${boot_log}" || :
  [ -x "/sbin/restorecon" ] &&
  /sbin/restorecon "${boot_log}" || :
fi 1>/dev/null 2>&1

if [ ${funcload:-0} -eq 0 ]
then

echo_success() {
  echo -en "\\033[60G"
  echo -n "[  OK  ]"
  echo -ne "\r"
  return 0
}

echo_failure() {
  echo -en "\\033[60G"
  echo -n "[FAILED]"
  echo -ne "\r"
  return 1
}

fi

start() {
  [ -x "${PG_BIN}/postmaster" ] || exit 5

  # Check for the PGDATA structure
  if [ -f "${PGDATA}/PG_VERSION" -a -d "${PGDATA}/base" ]
  then
    # Check version of existing PGDATA
    if [ -n "${PGMAJORVERSION}" ] &&
       [ $(cat "${PGDATA}/PG_VERSION") != "${PGMAJORVERSION}" ]
    then
      echo
      echo "An old version of the database format was found."
      echo "You need to upgrade the data format before using PostgreSQL."
      exit 1
    fi
  else
    # No existing PGDATA! Warn the user to initdb it.
    echo
    echo "${PGDATA} is missing. Use '${PG_BIN}/initdb' to initialize the cluster first."
    echo_failure
    echo
    exit 1
  fi

  [ "${PG_OOM_ADJ}" != "" ] &&
  echo "${PG_OOM_ADJ}" 1>/proc/self/oom_adj || :

  echo -n "Starting ${NAME} service: "

  ${SU} -l "${PGUSER}" -c \
  "${PG_BIN}/pg_crl start -D ${PGDATA} -o '-p ${PGPORT}' ${PGCTL_START_OPTS:--s -w}" \
    </dev/null 1>>"${boot_log}" 2>&1
  _RET=$?

  _pid=""

  if [ ${_RET:-1} -eq 0 ]
	then
    for _cnt in 1 2 3
    do
      [ -s "${PGDATA}/postmaster.pid" ] &&
      _pid=$(cat "${PGDATA}/postmaster.pid" 2>/dev/null) || :
      if [ -n "${_pid}" ]
      then break
      else sleep 1
      fi
    done
  fi 1>/dev/null 2>&1

  if [ -n "${_pid}" ]
  then
    echo_success
    echo "${_pid}" 1>"${pid_file}"
  else
    echo_failure
    [ ${script_reault} -eq 0 ] &&
    _RET=1
  fi
  echo

  return ${_RET}
}

stop() {
  echo -n  "Stopping ${NAME} service: "

  ${SU} -l "${PGUSER}" -c \
  "${PG_BIN}/pg_ctl stop -D '${PGDATA}' ${PGCTL_STOP_OPTS:--s -m fast}" \
    </dev/null 1>>"${boot_log}" 2>&1
  _RET=$?

  if [ ${_RET} -eq 0 ]
  then echo_success
  else echo_failure
  fi
  echo

  rm -f "${pid_file}" 1>/dev/null 2>&1

  return ${_RET}
}

restart() {
  stop
  start
  return $?
}

condrestart() {
  if [ -e "${pid_file}" ]
  then restart
  else start
  fi
  return $?
}

reload() {
  ${SU} -l "${PGUSER}" -c \
  "${PG_BIN}/pg_ctl reload -D '${PGDATA}' ${PGCTL_RELOAD_OPTS:--s}" \
  </dev/null
  return $?
}

status() {
  ${SU} -l "${PGUSER}" -c \
  "${PG_BIN}/pg_ctl status -D '${PGDATA}'" \
  </dev/null
  return $?
}

# See how we were called.
case "${1:-}" in
start|stop|restart|reload|condrestart|status)
  ${1}
  ;;
try-restart)
  condrestart
  ;;
force-reload)
  restart
  ;;
*)
  echo "Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
  exit 2
esac

exit ${_RET:-1}
