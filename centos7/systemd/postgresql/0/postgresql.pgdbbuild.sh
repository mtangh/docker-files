#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-dbbuild.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# LANG
export LANG=C

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

# Parse options
while [ $# -gt 0 ]
do
  case "$1" in
  PG*=*)
    [ -n "${1%%=*}" -a -n "${1#*=}" ] && {
      eval "P_${1}"; export "P_${1%%=*}"
    }
    ;;
  -f*)
    if [ -n "${1##*-f}" ]
    then PGSCFG="${1##*-f}"
    else shift; PGSCFG="${1}"
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-f /path/to/sysconfig] [PG*=VALUE ...] install-source-dir

_USAGE_
    exit 1
    ;;
  *)
    if [ -z "${SRCDIR}" -a -d "${1}" ]
    then SRCDIR="${1}"
    fi
    ;;
  esac
  shift
done

# Load the sysconfig/postgresql
[ -r "$PGSCFG" ] && {
  . "$PGSCFG" 1>/dev/null 2>&1 ||
  exit 127
}

# Check the PG* variables
[ -n "$PGUSER" ] || exit 90
[ -n "$PGHOME" ] || exit 91
[ -n "$PGROOT" ] || exit 92
[ -n "$PGDATA" ] || exit 93
[ -n "$PGPORT" ] || exit 94

# PCTL
PCTL="${PCTL:-$(type -P pg_ctl)}"
PCTL="${PCTL:-${PGROOT}/bin/pg_ctl}"

# PSQL
PSQL="${PSQL:-$(type -P psql)}"
PSQL="${PSQL:-${PGROOT}/bin/psql}"

# Check the bin
[ -x "${PCTL}" ] || exit 95
[ -x "${PSQL}" ] || exit 96

# PG_CTL Wrapper
__pgctl_wrapper() {
  local _command="$1"
  local pgstatus=0
  local pgctlopt=""
  local pgctlret=0
  local _waitfor=0
  : && {
    /bin/su - "${PGUSER}" -c "${PCTL} status -D ${PGDATA}"
    pgstatus=$?
  } 1>/dev/null 2>&1
  case "$_command" in
  status)
    [ $pgstatus -eq 0 ] && echo "RUNNING"
    pgctlret=$pgstatus
    ;;
  *)
    case "$_command" in
    start)
      [ $pgstatus -eq 0 ] &&
      _command=""
      _waitfor=1
      ;;
    stop)
      [ $pgstatus -ne 0 ] &&
      _command=""
      _waitfor=0
      ;;
    restart)
      [ $pgstatus -ne 0 ] &&
      _command="start"
      _waitfor=1
      ;;
    esac
    if [ -n "$_command" ]
    then
      pgctlret=999
      if [ -n "$(type -P systemctl 2>/dev/null)" ]
      then
        echo "PCTL: command 'systemctl' found."
        systemctl "$_command" postgresql; pgctlret=$?
        echo "PGTCL: systrmctl $_command postgresql; ret=$pgctlret."
      elif [ -n "$(type -P service 2>/dev/null)" ]
      then
        echo "PCTL: command 'service' found."
        service postgresql "$_command"; pgctlret=$?
        echo "PGTCL: service postgresql $_command; ret=$pgctlret."
      fi
      if [ -z "$pgctlret" ] || [ $pgctlret -ne 0 ]
      then
        pgctlopt="-D ${PGDATA} -s -t 300"
        [ "$_command" != "stop" ] &&
        pgctlopt=$(echo $pgctlopt "-o '-p ${PGPORT}' -w")
        [ "$_command" != "start" ] &&
        pgctlopt=$(echo $pgctlopt "-m fast")
        /bin/su - ${PGUSER} -c "${PCTL} $_command $pgctlopt"
        pgctlret=$?
        echo "PCTL: ${PCTL} $_command $pgctlopt - ret=$pgctlret."
      fi
      [ $pgctlret -eq 0 ] &&
      [ $_waitfor -ne 0 ] &&
      __waitforstartup
    fi
  esac
  return $pgctlret
}

# Waiting for startup
__waitforstartup() {
  local retrycnt=0
  for retrycnt in 0 1 2 3 4 5 6 7 8 9
  do
    sleep 2s;
    ${PSQL} -U ${PGUSER} -p ${PGPORT} -l &&
    break
  done 1>/dev/null 2>&1
  [ -n "$retrycnt" ] && [ $retrycnt -ge 9 ] && {
    echo "Could not connect to server." 1>&2
    exit 99
  }
  return 0
}

# Stdout
__stdout() {
  _tag="${1}"
  $AWK '{
  printf("%s: %s%s\n",
  "'"${BASE}"'","'"${_tag:+$_tag: }"'",$0);
  fflush();};' |
  $SED -r 's/\x1B\[([0-9]{1,2}(;[0-9]{1,2})*)?m//g'
  return 0
}

# cleanup function
__pgdbbuild_cleanup() {
  if [ -n "$PGSTAT" ]
  then __pgctl_wrapper restart
  else __pgctl_wrapper stop
  fi 1>/dev/null 2>&1
  return 0
}

# trap
trap \
  "__pgdbbuild_cleanup" \
  EXIT SIGTERM SIGINT SIGQUIT

# Main
: && {

  # Print PG*
  cat <<_EOF_
#
# DEFAULT PG* ENVIRONMENT VARIABLES ARE:
#
#  PGUSER=$PGUSER
#  PGHOME=$PGHOME
#  PGROOT=$PGROOT
#  PGDATA=$PGDATA
#  PGPORT=$PGPORT
#
_EOF_

  # PostgreSQL state
  PGSTAT=$(__pgctl_wrapper status)

  # PostgreSQL is running ?
  if [ -n "$PGSTAT" ]
  then echo "PostgreSQL server is running."
  else echo "PostgreSQL server is not running."
  fi

  # Stopping postgresql server, if started.
  [ -n "$PGSTAT" ] && {
    __pgctl_wrapper stop  #1>/dev/null 2>&1
  } || :

  # UPDATE *.service
  for service in $(cd "${SRCDIR}/" && ls -1 *.service 2>/dev/null)
  do
    [ -s "${SRCDIR}/${service}" ] || {
      continue
    }
    # System service file
    sys_service="/etc/systemd/system/${service}"
    # Print
    echo "UPDATE '$service' to '$sys_service'."
    # Check difference
    if [ -r "${sys_service}" ]
    then
      diff "${SRCDIR}/${service}" "${sys_service}" 1>/dev/null 2>&1 && {
        continue
      }
      [ -r "${sys_service}.ORIG" ] || {
        cp -pf "${sys_service}"{,.ORIG}
      }
    fi
    # Update service
    mv -f "${SRCDIR}/${service}" "${sys_service}" &&
    chown root:root "${sys_service}" &&
    chmod 0644 "${sys_service}" || {
      echo "Failed to update file '${config}'." 1>&2
    }
  done

  # UPDATE *.sysconfig
  for sysconfig in $(cd "${SRCDIR}/" && ls -1 *.sysconfig 2>/dev/null)
  do
    [ -s "${SRCDIR}/${sysconfig}" ] || {
      continue
    }
    # Installed sysconfig
    etc_sysconfig="/etc/sysconfig/${sysconfig%.sysconfig*}"
    # Print
    echo "UPDATE '$sysconfig' to '$etc_sysconfig'."
    # Check difference
    if [ -r "${etc_sysconfig}" ]
    then
      diff "${etc_sysconfig}" "${SRCDIR}/${sysconfig}" 1>/dev/null 2>&1 && {
        continue
      }
      [ -r "${etc_sysconfig}.ORIG" ] || {
        cp -pf "${etc_sysconfig}"{,.ORIG}
      }
    fi
    # Update sysconfig
    mv -f "${SRCDIR}/${sysconfig}" "${etc_sysconfig}" &&
    chown root:root "${etc_sysconfig}" &&
    chmod 0644 "${etc_sysconfig}" || {
      echo "Failed to update file '${config}'." 1>&2
    }
  done

  # Replacing PGDATA and PGPORT
  if [ -n "$P_PGDATA" -o -n "$P_PGPORT" ]
  then
    # Make temp
    cp -pf "${PGSCFG}" "${PGSCFG}.tmp"
    # Check PGDATA Param
    if [ -n "$P_PGDATA" ] && [ "$P_PGDATA" != "$PGDATA" ]
    then
      echo "CHANGE PGDATA '${PGDATA}' TO '${P_PGDATA}'."
      $SED -ri 's!^[ ]*PGDATA=[^ ]+[ ]*$!PGDATA='${P_PGDATA}'!g' "${PGSCFG}.tmp"
    fi
    # Check PGPORT Param
    if [ -n "$P_PGPORT" ] && [ "$P_PGPORT" != "$PGPORT" ]
    then
      echo "CHANGE PGPORT '${PGPORT}' TO '${P_PGPORT}'."
      $SED -ri 's!^[ ]*PGPORT=[^ ]+[ ]*$!PGPORT='${P_PGPORT}'!g' "${PGSCFG}.tmp"
    fi
  fi 2>/dev/null

  # Replacing sysconfig
  if [ -s "${PGSCFG}.tmp" ]
  then

    # Difference
    if diff "${PGSCFG}" "${PGSCFG}.tmp" 2>/dev/null
    then rm -f "${PGSCFG}.tmp"
    else mv -f "${PGSCFG}.tmp" "${PGSCFG}"
    fi

    # Print new PG*
    cat <<_EOF_
#
# NEW PG* ENVIRONMENT VARIABLES ARE:
#
#  PGUSER=$PGUSER
#  PGHOME=$PGHOME
#  PGROOT=$PGROOT
#  PGDATA=$PGDATA
#  PGPORT=$PGPORT
#
_EOF_

  fi 2>/dev/null

  # Reload sysconfig
  . "${PGSCFG}" || {
    echo "$THIS: ERROR: Failed to load sysconfig '${PGSCFG}'." 1>&2
    exit 100
  }

  # PSQL
  PSQL="${PSQL} -U${PGUSER} -p${PGPORT}"

  # Replacing configs
  for config in $(cd "${SRCDIR}/" && ls -1 *.conf 2>/dev/null)
  do
    [ -s "${SRCDIR}/${config}" ] || {
      continue
    }
    # Print
    echo "REPLACE '$config' to '${PGDATA}/${config}'."
    # Check difference
    if [ -r "${PGDATA}/${config}" ]
    then
      diff "${PGDATA}/${config}" "${SRCDIR}/${config}" 1>/dev/null 2>&1 && {
        continue
      }
      [ -r "${PGDATA}/${config}.ORIG" ] || {
        cp -pf "${PGDATA}/${config}"{,.ORIG}
      }
    fi
    # Update conf file
    mv -f "${SRCDIR}/${config}" "${PGDATA}/${config}" &&
    chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" &&
    chmod 0644 "${PGDATA}/${config}" || {
      echo "Failed to update file '${config}'." 1>&2
    }
  done

  # Scaning source dir
  for srcdir in $(cd "${SRCDIR}" && ls -1 *.sql 2>/dev/null |sort)
  do
    [ -n "$srcdir" ] || {
      continue
    }
    # Ignore roles*
    echo "${srcdir%.*}" |grep -Ei '^(roles)' 1>/dev/null 2>&1 && {
      continue
    }
    # Update list
    PGDATABASES="${PGDATABASES:+$PGDATABASES }${srcdir%.*}"
  done

  # PGDATABASES
  if [ -n "$PGDATABASES" ]
  then echo "DATABASE FOUND: $PGDATABASES"
  else echo "DATABASE NOT FOUND"; exit 0
  fi

  # Startup postgresql server
  __pgctl_wrapper start #1>/dev/null 2>&1

  # Import roles
  if [ -s "${SRCDIR}/roles.sql" ]
  then
    cat "${SRCDIR}/roles.sql" |${PSQL} || {
      echo "$THIS: ERROR: SQL Execution failed. SQL='roles.sql'." 1>&2
      exit 101
    }
  fi || :

  # Import database schema
  for PGDATABASE in $PGDATABASES
  do

    # Print
    echo "PGDATABASE '$PGDATABASE'"

    # Make schema
    for sql in ${SRCDIR}/{$PGDATABASE,schema}.sql
    do
      [ -s "$sql" ] || {
        continue;
      }
      # Print
      echo "CREATEDB '$sql'"
      # Create DB SQL
      cat "$sql" |${PSQL} || {
        echo "$THIS: ERROR: SQL Execution failed. SQL='${sql}'." 1>&2
        exit 102
      }
      # pgTap
      if [ -z "$PGTAP_VER" ]
      then
        echo 'CREATE EXTENSION pgtap;' |${PSQL} -d ${PGDATABASE} || {
          echo "$THIS: ERROR: Failed to CREATE EXTENTION. ’pgtap''." 1>&2
          exit 103
        }
      fi || :
      # Break
      break
    done |
    __stdout "$PGDATABASE"
    # for sql in ${SRCDIR}/{$PGDATABASE,schema}.sql

    # Init-data
    for data_dir in ${SRCDIR}/{init-data,$PGDATABASE}
    do

      # Print
      echo "LOAD FROM ${data_dir}.d"

      # Lookup data dir
      if [ ! -d "${data_dir}" -a ! -d "${data_dir}.d" ]
      then
        if [ -e "${data_dir}.tgz" ]
        then
          # Found ${data_dir}.tgz
          echo "$PGDATABASE: '${data_dir}.tgz' found."
          # Decompress
          ( cd "${data_dir%/*}/" && tar -zxvf "${data_dir}.tgz" ) && {
            echo "$THIS: ERROR: SQL Execution failed. SQL='${sql}'." 1>&2
          }
        fi
      fi
      if [ -d "${data_dir}.d" ]
      then data_dir="${data_dir}.d"
      fi

      # Found ?
      [ -d "${data_dir}" ] || {
        echo "Not found '${data_dir}.d'"
        continue
      }

      # Import data
      for sql in ${data_dir}/*.sql;
      do
        [ -s "$sql" ] || {
          continue
        }
        # Print
        echo "DATA=$sql"
        # Execute SQL
        cat "$sql" |${PSQL} -d ${PGDATABASE} || {
          echo "$THIS: ERROR: SQL Execution failed. SQL='${sql}'." 1>&2
          exit 104
        }
      done  # for sql in ${data_dir}/*.sql

    done |
    __stdout "$PGDATABASE"
    # for data_dir in ${SRCDIR}/{init-data,$PGDATABASE}

  done
  # for PGDATABASE in $PGDATABASES

} |
__stdout

# end
exit 0
