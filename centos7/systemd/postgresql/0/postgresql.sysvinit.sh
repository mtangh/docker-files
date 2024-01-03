#!/bin/sh
#
# postgresql    This is the init script for starting up the PostgreSQL
#               server.
#
# chkconfig: - 64 36
# description: PostgreSQL database server.
#
# config: /etc/sysconfig/postgresql
#
### BEGIN INIT INFO
# Provides: postgresql
# Required-Start: $network $syslog
# Required-Stop: $network $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Description: Start, stop and restart postgresql
# Short-Description: start and stop postgresql
### END INIT INFO

# This script is slightly unusual in that the name of the daemon (postmaster)
# is not the same as the name of the subsystem (postgresql)

# Find the name of the script
NAME="${0##*/}"
if [ "${NAME:0:1}" = "S" -o "${NAME:0:1}" = "K" ]
then
  NAME=${NAME:3}
fi

# Source function library.
if [ -f "/etc/rc.d/init.d/functions" ]
then . /etc/rc.d/init.d/functions
else :
fi

# Get network config.
if [ -f "/etc/sysconfig/network" ]
then . /etc/sysconfig/network
else :
fi

# functions is not loaded.
if [ -z "${BOOTUP:-}" ]
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

else :
fi # if [ -z "${BOOTUP:-}" ]

# For SELinux we need to use 'runuser' not 'su'
if [ -x "/sbin/runuser" ]
then SU=runuser
else SU=su
fi

# Get postgresql config.
. "/etc/sysconfig/${NAME}"
if [ $? -ne -0 ]
then
  echo "${NAME}: ERROR: no such file or directory '/etc/sysconfig/${NAME}'."
  exit 2
else :
fi

# Set defaults for configuration variables
PGHOME="${PGHOME:-/opt/postgresql}"
PGROOT="${PGROOT:-/opt/postgresql}"
PG_BIN="${PG_BIN:-/opt/postgresql/bin}"
PGUSER="${PGUSER:-postgres}"
PGPORT="${PGPORT:-5432}"
PGDATA="${PGDATA:-/opt/postgresql/data}"

# Value to set as postmaster process's oom_adj
PG_OOM_ADJ="${PG_OOM_ADJ:--17}"

# PGVERSION is the full package version, e.g., 8.4.0
# Note: the specfile inserts the correct value during package build
PGVERSION="${PGSQLVER:-}"
# PGMAJORVERSION is major version, e.g., 8.4 (this should match PG_VERSION)
PGMAJORVERSION=$(echo "${PGVERSION}" |sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' 2>/dev/null)

# Exports
export PGDATA
export PGPORT

# boot log file
boot_log="/var/log/${NAME}-boot.log"

# PID file
pid_file="${PGDATA}/postmaster.pid"

# Timeout
STARTUP_WAIT=60
SHUTDOWNWAIT=120

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

is_running() {
  _pid=$(
    [ -s "${pid_file}" ] &&
    cat "${pid_file}" 2>/dev/null || :; )
  [ -n "$(kill -0 ${_pid} 2>/dev/null)" ]
  return $?
}

start() {
  [ -x "${PGROOT}/bin/postmaster" ] || exit 5

  if is_running
  then
    echo "${NAME} is already running (pid: ${_pid:-???})"
    _RET=1
  else

    echo -n "Starting ${NAME} service: " && {

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
        echo "${PGDATA} is missing. Use '${PGROOT}/bin/initdb' to initialize the cluster first."
        echo_failure
        echo
        exit 1
      fi

      [ "${PG_OOM_ADJ}" != "" ] &&
      echo "${PG_OOM_ADJ}" 1>/proc/self/oom_adj || :

      ${SU} -l "${PGUSER}" -c \
      "${PGROOT}/bin/pg_crl start -D ${PGDATA} -o '-p ${PGPORT}' ${PGCTL_START_OPTS:--s -w}" \
      </dev/null
      _RET=$?

      if [ ${_RET:-1} -eq 0 ]
      then

        _cnt=0

        while [ ${_cnt} -gt ${STARTUP_WAIT} ]
        do
          is_running && break || :
          echo "Waiting for processes to startup."
          sleep 1; (( _cnt++ ))
        done

        if [ ${_cnt} -le ${STARTUP_WAIT} ]
        then
          echo "The startup was successful. pid=${_pid:-???}."
        else
          echo "Failed to startup for ${NAME}."
          _RET=1
        fi

      fi

    } 1>>"${boot_log}" 2>&1

    if [ ${_RET:-1} -eq 0 ]
    then
      echo_success
    else
      echo_failure
      [ ${_RET} -eq 0 ] && _RET=1
    fi
    echo

  fi

  return ${_RET}
}

stop() {
  if is_running
  then

    echo -n  "Stopping ${NAME} service: " && {

      ${SU} -l "${PGUSER}" -c \
      "${PGROOT}/bin/pg_ctl stop -D '${PGDATA}' ${PGCTL_STOP_OPTS:--s -m fast}" \
      </dev/null
      _RET=$?

      if [ ${_RET:-1} -eq 0 ]
      then

        _cnt=0

        while [ ${_cnt} -gt ${SHUTDOWNWAIT} ]
        do
          is_running || break
          echo "Waiting for processes (pid:${_pid:-???}) to exit."
          sleep 1 && (( _cnt++ ))
        done

        if [ ${_cnt} -le ${SHUTDOWNWAIT} ]
        then
          echo "The shutdown was successful."
        else
          echo "Killing processes (pid:${_pid:-???}) which didn't stop after ${SHUTDOWNWAIT} seconds."
          [ -n "${_pid:-}" ] && kill -9 ${_pid:-} || :
          _RET=1
        fi 

      fi 

    } 1>>"${boot_log}" 2>&1

    if [ ${_RET} -eq 0 ]
    then
      echo_success
    else
      echo_failure
      [ ${_RET:-1} -eq 0 ] && _RET=1
    fi
    echo
  
  else
    echo "${NAME} is not running"
    _RET=1
  fi

  return ${_RET}
}

restart() {
  stop
  start
  return $?
}

condrestart() {
  if is_running
  then restart
  else start
  fi
  return $?
}

reload() {
  ${SU} -l "${PGUSER}" -c \
  "${PGROOT}/bin/pg_ctl reload -D '${PGDATA}' ${PGCTL_RELOAD_OPTS:--s}" \
  </dev/null
  return $?
}

status() {
  ${SU} -l "${PGUSER}" -c \
  "${PGROOT}/bin/pg_ctl status -D '${PGDATA}'" \
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
  echo "Usage: ${NAME} {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
  exit 2
esac

exit ${_RET:-1}
