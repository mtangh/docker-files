#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# PG sysconfig
PGSCFG=/etc/sysconfig/postgresql

# Source dir.
SRCDIR=

# PG* Envs
PGUSER=
PGHOME=
PGDATA=
PGPORT=

# LANG
export LANG=C

# Load the sysconfig/postgresql
[ -r "$PGSCFG" ] && {
  . "$PGSCFG" 1>/dev/null 2>&1 ||
  exit 127
}

P_PGDATA=""
P_PGPORT=""

# parameters
while [ $# -gt 0 ]
do
  case "$1" in
  -D*)
    if [ -n "${1##*-D}" ]
    then
      P_PGDATA="${1##*-D}"
    elif [ -n "$2" ]
    then
      P_PGDATA="$2"
      shift
    fi
    ;;
  -p*)
    if [ -n "${1##*-p}" ]
    then
      P_PGPORT="${1##*-p}"
    elif [ -n "$2" ]
    then
      P_PGPORT="$2"
      shift
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-D data-dir] [-p port] install-source-dir
_USAGE_
    ;;
  *)
    if [ -z "${SRCDIR}" ] && [ -d "$1" ]
    then
      SRCDIR="$1"
    fi
    ;;
  esac
  shift
done

# Check the PG* variables
[ -n "$PGUSER" ] || exit 90
[ -n "$PGHOME" ] || exit 91
[ -n "$PGDATA" ] || exit 92
[ -n "$PGPORT" ] || exit 93

# INIT SCRIPT
PGINIT="/etc/rc.d/init.d/postgresql"

# PSQL
PSQL="${PGHOME}/bin/psql"

# Check the bin
[ -x "${PGINIT}" ] || exit 95
[ -x "${PSQL}" ]   || exit 96

# Waiting for startup
waitforstartup() {
  local retrycnt=0
  for retrycnt in 0 1 2 3 4 5 6 7 8 9
  do
    sleep 2s; ${PSQL} -U ${PGUSER} -p ${PGPORT} -l && break
  done 1>/dev/null 2>&1
  [ -n "$retrycnt" ] && [ $retrycnt -ge 9 ] && {
    echo "$THIS: Could not connect to server." 1>&2
    exit 99
  }
  return 0
}

# cleanup function
cleanup() {
  if [ -n "$PGSTAT" ]
  then $PGINIT restart
  else $PGINIT stop
  fi 1>/dev/null 2>&1
  return 0
}

# trap
trap cleanup EXIT SIGTERM SIGINT SIGQUIT

# Print PG*
cat <<_EOF_
$THIS: DEFAULT PG* ENVIRONMENT VARIABLES ARE:
$THIS: PGUSER=$PGUSER
$THIS: PGHOME=$PGHOME
$THIS: PGDATA=$PGDATA
$THIS: PGPORT=$PGPORT
_EOF_

# PostgreSQL state
PGSTAT=$($PGINIT status 1>/dev/null 2>&1 && echo 'RUNNING')

# PostgreSQL is running ?
if [ -n "$PGSTAT" ]
then
  echo "$THIS: PostgreSQL server is running."
else
  echo "$THIS: PostgreSQL server is not running."
fi

# Replacing PGDATA and PGPORT
if [ -n "$P_PGDATA" -o -n "$P_PGPORT" ]
then
  cp "${PGSCFG}" "${PGSCFG}.tmp"
  if [ -n "$P_PGDATA" ]
  then
    echo "$THIS: CHANGE PGDATA '${PGDATA}' TO '${P_PGDATA}'."
    sed -i 's!^[ ]*PGDATA=[^ ]*[ ]*$!PGDATA='${P_PGDATA}'!g' "${PGSCFG}.tmp"
  fi
  if [ -n "$P_PGPORT" ]
  then
    echo "$THIS: CHANGE PGPORT '${PGPORT}' TO '${P_PGPORT}'."
    sed -i 's!^[ ]*PGPORT=[^ ]*[ ]*$!PGPORT='${P_PGPORT}'!g' "${PGSCFG}.tmp"
  fi
fi 2>/dev/null

# Replacing sysconfig
if [ -s "${PGSCFG}.tmp" ]
then
  diff "${PGSCFG}" "${PGSCFG}.tmp"
  if [ -$? -eq 0 ]
  then
    rm -f "${PGSCFG}.tmp"
  else
    [ -n "$PGSTAT" ] && { ${PGINIT} condstop; }
    mv -f "${PGSCFG}.tmp" "${PGSCFG}" && . "${PGSCFG}"
    [ -n "$PGSTAT" ] && { ${PGINIT} start; waitforstartup; }
  fi 
  cat <<_EOF_
$THIS: NEW PG* ENVIRONMENT VARIABLES ARE:
$THIS: PGUSER=$PGUSER
$THIS: PGHOME=$PGHOME
$THIS: PGDATA=$PGDATA
$THIS: PGPORT=$PGPORT
_EOF_
fi 2>/dev/null

# PSQL
PSQL="${PSQL} -U ${PGUSER} -p ${PGPORT}"

# Replacing configs
for config in $(cd "${SRCDIR}/" && ls -1 *.conf 2>/dev/null)
do
  echo "$THIS: REPLACE '$config'."
  [ -r "${PGDATA}/${config}" ] &&
  [ ! -r "${PGDATA}/${config}.ORIG" ] &&
    cp -pf "${PGDATA}/${config}"{,.ORIG} 
  [ -r "${SRCDIR}/${config}" ] && {
    mv -f "${SRCDIR}/${config}" "${PGDATA}/${config}" &&
    chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" &&
    chmod 0644 "${PGDATA}/${config}"
  }
done

# Scaning source dir
for srcdir in $(cd "${SRCDIR}" && ls -1 *.sql |sort 2>/dev/null)
do
  [ -n "$srcdir" ] ||
    continue
  echo "${srcdir%.*}" |
  grep -Ei '^(roles)' 1>/dev/null 2>&1 &&
    continue
  PGDATABASES=$(echo ${PGDATABASES} ${srcdir%.*})
done

# PGDATABASES
if [ -n "$PGDATABASES" ]
then
  echo "$THIS: DATABASE FOUND: $PGDATABASES"
else
  echo "$THIS: DATABASE NOT FOUND"
  exit 0 
fi

# Startup postgresql server
[ -z "$PGSTAT" ] && {
  ${PGINIT} start #1>/dev/null 2>&1
  waitforstartup
}

# Import roles
[ ! -r "${SRCDIR}/roles.sql" ] || {
  cat "${SRCDIR}/roles.sql" |${PSQL} || exit 101
}

# Import database schema
for PGDATABASE in $PGDATABASES
do

  echo "$THIS: PGDATABASE '$PGDATABASE'"
  
  for sql in ${SRCDIR}/{$PGDATABASE,schema}.sql
  do
    [ -r "$sql" ] || continue
    echo "$THIS: $PGDATABASE: CREATEDB '$sql'"
    cat "$sql" |${PSQL} ||
      exit 101
    [ -z "$PGTAP_VER" ] || {
      echo 'CREATE EXTENSION pgtap;' |
      ${PSQL} -d ${PGDATABASE} ||
        exit 102
    }
    break
  done

  for data_dir in ${SRCDIR}/{init-data,$PGDATABASE}
  do
  
    echo "$THIS: $PGDATABASE: LOAD FROM ${data_dir}.d"

    if [ ! -d "${data_dir}" ] &&
       [ ! -d "${data_dir}.d" ]
    then
      if [ -e "${data_dir}.tgz" ]
      then
        ( cd "${data_dir%/*}/" && tar -zxvf "${data_dir}.tgz" )
      fi
    fi

    if [ -d "${data_dir}.d" ]
    then
      data_dir="${data_dir}.d"
    elif [ ! -d "${data_dir}" ]
    then
      echo "$THIS: $PGDATABASE: Not found '${data_dir}.d'"
      continue
    fi

    for sql in ${data_dir}/*.sql;
    do
      [ -r "$sql" ] || continue
      echo "$THIS: $PGDATABASE: DATA=$sql"
      cat $sql |${PSQL} -d ${PGDATABASE} ||
        exit 103
    done

  done

done

# end
exit $?
