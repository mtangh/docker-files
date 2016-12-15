#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# PG sysconfig
PGSCFG=/etc/sysconfig/postgresql

# Source dir.
SRCDIR=

# Shutdown flag
PGSHUT=0

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

# parameters
while [ $# -gt 0 ]
do
  case "$1" in
  -p*)
    if [ -n "${1##*-p}" ]
    then
      PGPORT="${1##*-p}"
    elif [ -n "$2" ]
    then
      PGPORT="$2"
      shift
    fi
    ;;
  -shutdown)
    PGSHUT=1
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-p port] install-source-dir
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

# Check the bin
[ -x "/etc/init.d/postgresql" ] || exit 95
[ -x "${PGHOME}/bin/psql" ]     || exit 96

# PSQL
PSQL="${PGHOME}/bin/psql -U ${PGUSER} -p ${PGPORT}"

# print PG*
cat <<_EOF_
$THIS: PGUSER=$PGUSER
$THIS: PGHOME=$PGHOME
$THIS: PGDATA=$PGDATA
$THIS: PGPORT=$PGPORT
_EOF_

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
[ -n "$PGDATABASES" ] || {
  exit 0 
}

# print DATABASES
echo "$THIS: DATABASE FOUND: $PGDATABASES"

# Replacing server port
if [ -r "$PGSCFG" -a -n "$PGPORT" ]
then
  cat "$PGSCFG" |
  grep -E '^[ ]*PGPORT='${PGPORT}'[ ]*$' 1>/dev/null 2>&1 || {
    echo "$THIS: Change the server port: PGPORT=$PGPORT."
    /etc/init.d/postgresql condstop #1>/dev/null 2>&1
    sed -i 's/^[ ]*PGPORT=[0-9]*[ ]*$/PGPORT='${PGPORT}'/g' "$PGSCFG"
    /etc/init.d/postgresql start #1>/dev/null 2>&1
  }
fi

# Replace configs
for config in $(cd "${SRCDIR}/" && ls -1 *.conf 2>/dev/null)
do
  [ -r "${PGDATA}/${config}" ] &&
  [ ! -r "${PGDATA}/${config}.ORIG" ] &&
    cp -pf "${PGDATA}/${config}"{,.ORIG} 
  [ -r "${SRCDIR}/${config}" ] && {
    mv -f "${SRCDIR}/${config}" "${PGDATA}/${config}" &&
    chown "${PGUSER}:${PGUSER}" "${PGDATA}/${config}" &&
    chmod 0644 "${PGDATA}/${config}"
  }
done

# Startup postgresql
/etc/init.d/postgresql condrestart #1>/dev/null 2>&1

# Trap signal
[ $PGSHUT -ne 0 ] && {
  trap -- "/etc/init.d/postgresql stop" EXIT SIGTERM SIGINT SIGQUIT
}

# Waiting for startup
for retrycnt in 0 1 2 3 4 5 6 7 8 9
do
  sleep 1s
  ${PSQL} -l 1>/dev/null 2>&1 && break
done

[ -n "$retrycnt" ] &&
[ $retrycnt -ge 9 ] && {
  echo "$THIS: Could not connect to server: PGPORT=$PGPORT." 1>&2
  exit 99
}

# Import roles
[ ! -r "${SRCDIR}/roles.sql" ] || {
  cat "${SRCDIR}/roles.sql" |${PSQL} || exit 100
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
