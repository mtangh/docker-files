#!/bin/bash
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)
# shell opts
set -ux -o errtrace -o functrace -o pipefail

# LANG
LANG=C
export LANG

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# YUM or DNF
YUM=""
if [ -x "$(type -P dnf)" ]
then YUM="dnf -v -y"
elif [ -x "$(type -P yum)" ]
then YUM="yum -v -y"
fi

# Functions
. "${CDIR}/pgfunctions.sh" &>/dev/null || {
  echo "${THIS}: ERROR: no such file or directory 'pgfunctions.sh'." 1>&2
  exit 2
}

# PG_CTL Wrapper
__pgctl_wrapper() {
  local _command="${1:-}"
  local pgstatus=0
  local pgctlopt=""
  local pgctlret=0
  local _waitfor=0
  : && {
    /bin/su - "${PGUSER}" -c "${PCTL} status -D ${PGDATA}"
    pgstatus=$?
  } &>/dev/null
  case "${_command:-}" in
  status)
    [ ${pgstatus:-1} -eq 0 ] && echo "RUNNING" || :
    return ${pgstatus:-1}
    ;;
  start)
    [ ${pgstatus} -eq 0 ] && return ${pgstatus} || :
    _waitfor=1
    ;;
  stop)
    [ ${pgstatus} -ne 0 ] && return ${pgstatus} || :
    _waitfor=0
    ;;
  restart)
    [ ${pgstatus} -ne 0 ] && _command="start" || :
    _waitfor=1
    ;;
  esac
  if [ -n "${_command:-}" ]
  then
    pgctlret=1
    if [ -n "$(type -P systemctl 2>/dev/null)" ]
    then
      echo "PGCTL: command 'systemctl' found."
      systemctl "${_command}" postgresql; pgctlret=$?
      echo "PGCTL: systemctl ${_command} postgresql; ret=${pgctlret}."
    elif [ -n "$(type -P service 2>/dev/null)" ]
    then
      echo "PGCTL: command 'service' found."
      service postgresql "${_command}"; pgctlret=$?
      echo "PGCTL: service postgresql ${_command}; ret=${pgctlret}."
    fi
    if [ ${pgctlret:-1} -ne 0 ]
    then
      pgctlopt="-D ${PGDATA} -s"
      [ "${_command}" != "stop" ] &&
      pgctlopt=$(echo ${pgctlopt} "-o '-p ${PGPORT}' -w")
      [ "${_command}" != "start" ] &&
      pgctlopt=$(echo ${pgctlopt} "-m fast")
      /bin/su - ${PGUSER} -c "${PCTL} ${_command} ${pgctlopt}"
      pgctlret=$?
      echo "PGCTL: ${PCTL} ${_command} ${pgctlopt} - ret=${pgctlret}."
    fi
    [ ${pgctlret:-1} -eq 0 -a \
      ${_waitfor:-0} -ne 0 ] &&
      __waitforstartup || :
  fi
  return ${pgctlret:-1}
}

# Waiting for startup
__waitforstartup() {
  local retrycnt=${PGSTARTTIMEOUT:-10}
  local pgsqlpid=""
  while true
  do
    pgsqlpid=$(
      head -n 1 "${PGDATA}/postmaster.pid" 2>/dev/null)  
    [ -n "${pgsqlpid}" ] ||
      break
    retrycnt=$(( retrycnt - 1 ))
    # pid_file does not exist yet, wait a sec more
    [ ${retrycnt} -ge 0 ] &&
      sleep 1 &&
      continue
    break
  done &>/dev/null
  [ ${retrycnt:-0} -le 0 ] && {
    echo "Could not connect to server." 1>&2
    exit 16
  }
  return 0
}

# cleanup function
__pgdbbuild_cleanup() {
  if [ -n "${PGSTAT:-}" ]
  then __pgctl_wrapper restart
  else __pgctl_wrapper stop
  fi &>/dev/null
  return 0
}

# PG sysconfig
PGSCFG="/etc/sysconfig/postgresql"

# Source dir.
SRCDIR=

# PG* Envs
PGUSER=
PGHOME=
PGROOT=
PGDATA=
PGPORT=

# Parameters
P_PGUSER=""
P_PGHOME=""
P_PGROOT=""
P_PGDATA=""
P_PGPORT=""

# trap
trap \
  "__pgdbbuild_cleanup" \
  EXIT ERR SIGTERM SIGINT SIGQUIT

# Parse options
while [ $# -gt 0 ]
do
  case "${1:-}" in
  -f*)
    if [ -n "${1##-f}" ]
    then PGSCFG="${1##-f}"
    else shift; PGSCFG="${1:-}"
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: ${THIS} [-f /path/to/sysconfig] install-source-dir

_USAGE_
    exit 1
    ;;
  *)
    if [ -z "${SRCDIR:-}" -a -d "${1:-}" ]
    then SRCDIR="${1:-}"
    fi
    ;;
  esac
  shift
done

# Load the sysconfig/postgresql
[ -r "${PGSCFG:-X}" ] &&
. "${PGSCFG}" &>/dev/null || {
  echo "${THIS}: ERROR: Failed to load sysconfig '${PGSCFG}'. " 1>&2
  exit 2
}

# Check the PG* variables
[ -n "${PGUSER}" -a \
  -n "${PGHOME}" -a \
  -n "${PGROOT}" -a \
  -n "${PGDATA}" -a \
  -n "${PGPORT}" ] || {
  echo "${THIS}: ERROR: Some or all of the required parameters PG* are not set. " 1>&2
  exit 22
}

# PCTL
PCTL="${PCTL:-$(type -P pg_ctl)}"
PCTL="${PCTL:-${PGROOT}/bin/pg_ctl}"

# PSQL
PSQL="${PSQL:-$(type -P psql)}"
PSQL="${PSQL:-${PGROOT}/bin/psql}"

# Check the bin
[ -x "${PCTL}" -a \
  -x "${PSQL}" ] || {
  echo "${THIS}: ERROR: Command not found. 'pg_ctl' and/or 'psql'. " 1>&2
  exit 2
}

# Exit state
EXIT_STATE=0

# Main
: "Main" && {

##
## [Contents]
##
## SRCDIR/
##   +- roles.sql
##   +- PGDATABASE.sql
##   +- PGDATAVASE.data/
##        +- data.sql ...
##

  # Print PG*
cat <<_EOF_
#
# DEFAULT PG* ENVIRONMENT VARIABLES ARE:
#
#  PGUSER=${PGUSER}
#  PGHOME=${PGHOME}
#  PGROOT=${PGROOT}
#  PGDATA=${PGDATA}
#  PGPORT=${PGPORT}
#
_EOF_

  # PostgreSQL state
  PGSTAT=$(__pgctl_wrapper status)

  # Startup postgresql server
  if [ -z "${PGSTAT:-}" ]
  then
    __pgctl_wrapper start #&>/dev/null
  fi

  # PSQL
  PSQL="${PSQL} -U${PGUSER} -p${PGPORT}"

  # Source Dir
  SRCDIR="${SRCDIR:-.}"

  # Databases
  PGDATABASES=""

  # Deploy the contents of the source directory.
  pushd "${SRCDIR}/" &&
  echo "# Unpacking gzip files." && {

    # Unpack the compressed file.
    for file in $( : && {
      ls -1 *.tgz *.gz 
      } 2>/dev/null || :; )
    do
      echo "Unpacking '${file}'." &&
      case "${file:-}" in
      *.tar.gz|*.tgz)
        _dir="${file%/*}"
        tar -C "${_dir}" -zxvf "${file}"
        ;;
      *.gz)
        gunzip "${file}"
        ;;
      *)
        ;;
      esac ||
      EXIT_STATE=$?
    done

  } &&
  echo "# Replacing configs." && {

    for _cfg in $( : && {
      ls -1 *.conf 2>/dev/null
      } || :; )
    do
      [ -s "${_cfg}" ] ||
        continue
      # Print
      echo "REPLACE '${_cfg}' to '${PGDATA}/${_cfg}'."
      # Check difference
      if [ -r "${PGDATA}/${_cfg}" -a \
         ! -r "${PGDATA}/${_cfg}.ORIG" ]
      then
        cp -pf "${PGDATA}/${_cfg}"{,.ORIG}
      fi
      # Update conf file
      : && {
        mv -f "${_cfg}" "${PGDATA}/${_cfg}" &&
        chown "${PGUSER}:${PGUSER}" "${PGDATA}/${_cfg}" &&
        chmod 0644 "${PGDATA}/${_cfg}"
      } || {
        EXIT_STATE=$?
        echo "Failed to update file '${_cfg}'." 1>&2
      }
    done

    # Check state
    [ ${EXIT_STATE:-1} -eq 0 ]

  } &&
  echo "# Import roles." && {

    for sqlf in ROLES roles
    do
      [ -s "${sqlf}.sql" ] ||
        continue
      cat "${sqlf}.sql" |${PSQL} || {
        EXIT_STATE=$?
        echo "SQL Execution failed. SQL='roles.sql'." 1>&2
      }
      # Break
      break
    done

    # Check state
    [ ${EXIT_STATE:-1} -eq 0 ]

  } &&
  echo "# Scaning source dir." && {

    for name in $(
      ls -1d *.sql *.schema 2>/dev/null |
      ${SED} -re 's/[.][^.]+$//' |
      sort -u || :; )
    do
      [ -n "${name}" ] ||
        continue
      # Ignore roles*
      echo "${name}" |egrep -i '^(roles)' &>/dev/null &&
        continue || :
      # Update list
      PGDATABASES="${PGDATABASES:+${PGDATABASES} }${name}"
    done

    # PGDATABASES
    if [ -n "${PGDATABASES}" ]
    then echo "DATABASE FOUND: ${PGDATABASES}"
    else echo "DATABASE NOT FOUND"
    fi

    # Check state
    [ -n "${PGDATABASES}" ]

  } &&
  echo "# Import database schema." && {

    for PGDATABASE in ${PGDATABASES}
    do
      echo "PGDATABASE '${PGDATABASE}'" && {

        # Create database
        for sqlf in $( : && {
          ls -1d ${PGDATABASE}.sql
          ls -1d ${PGDATABASE}.schema/*.sql
          } 2>/dev/null || :; )
        do
          [ -s "${sqlf}" ] ||
            continue;
          # Print
          echo "CREATEDB '${sqlf}'"
          # Create DB SQL
          cat "${sqlf}" |
          ${PSQL} -d"${PGDATABASE}" || {
            EXIT_STATE=$?
            echo "SQL Execution failed. SQL='${sqlf}'." 1>&2
          }
        done ||
        EXIT-STATE=$?
        [ ${EXIT_STATE:-1} -eq 0 ] ||
        break

        # Init-data
        for sqlf in $( : && {
          ls -1d ${PGDATABASE}.data/*.sql
          } 2>/dev/null || :; )
        do
          [ -s "${sqlf}" ] ||
            continue
          # Print
          echo "LOAD DATA=${sqlf}"
          # Execute SQL
          cat "${sqlf}" |
          ${PSQL} -d"${PGDATABASE}" || {
            EXIT_STATE=$?
            echo "SQL Execution failed. SQL='${sqlf}'." 1>&2
          }
        done ||
        EXIT-STATE=$?
        [ ${EXIT_STATE:-1} -eq 0 ] ||
        break

        # pgTap
        if [ -n "${PGTAPVER}" ]
        then
          echo 'CREATE EXTENSION pgtap;' |
          ${PSQL} -d"${PGDATABASE}" || {
            EXIT_STATE=$?
            echo "Failed to CREATE EXTENTION. ’pgtap''." 1>&2
          }
        else :
        fi

        [ ${EXIT_STATE:-1} -eq 0 ] ||
        break

      } 1> >(__stdout "${PGDATABASE}")
    done
    # for PGDATABASE in ${PGDATABASES}

    # Check state
    [ ${EXIT_STATE:-1} -eq 0 ]

  } &&
  popd ||
  EXIT_STATE=$?

} 1> >(__stdout) 2> >(__stderr) 3>&1
# : "Main" && { ...

# Wait
__wait $! &>/dev/null || :

# end
exit ${EXIT_STATE:-1}
