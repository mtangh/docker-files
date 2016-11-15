#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Load the docker-pg.rc
for dir in $CDIR{,/db,/..,/../db}
do
  [ -e "$dir/docker-pg.rc" ] && {
    . $dir/docker-pg.rc ||
    exit 127
  }
done

# Check the PG* variables
[ -n "$PGHOME" ]  || exit 90
[ -n "$PGPORT" ]  || exit 91
[ -n "$PGUSER" ]  || exit 92

# Check the bin
[ -x /etc/init.d/postgresql ] || exit 95
[ -x "${PGHOME}/bin/psql" ]   || exit 96

# PGDATABASES
[ -n "$PGDATABASE" ] &&
[ -z "$PGDATABASES" ] &&
  PGDATABASES="$PGDATABASE"

# PSQLCMD
PSQLCMD="${PGHOME}/bin/psql -U ${PGUSER} -p ${PGPORT}"

# Startup postgres
/etc/init.d/postgresql start 1>/dev/null 2>&1

# Waiting for startup
for c in 0 1 2 3 4 5 6 7 8 9
do
  sleep 1s
  ${PSQLCMD} -l 1>/dev/null 2>&1 &&
    break
done

# Import roles
[ -n "$PGDATABASES" ] &&
[ -r "$CDIR/roles.sql" ] && {
  cat "$CDIR/roles.sql" |${PSQLCMD} ||
  exit 100
} || :

# Import database schema
[ -z "$PGDATABASES" ] ||
for PGDATABASE in $PGDATABASES
do

  echo "$THIS: PGDATABASE '$PGDATABASE'"
  
  for sql in $CDIR/{$PGDATABASE,schema}.sql
  do
    [ -r "$sql" ] || continue
    echo "$THIS: $PGDATABASE: CREATEDB '$sql'"
    cat "$sql" |${PSQLCMD} ||
      exit 101
    [ -z "$PGTAP_VER" ] || {
      echo 'CREATE EXTENSION pgtap;' |
      ${PSQLCMD} -d ${PGDATABASE} ||
        exit 102
    }
    break
  done

  for data_dir in $CDIR{,/db}/{init-data,$PGDATABASE}
  do
  
    echo "$THIS: $PGDATABASE: LOAD FROM ${data_dir}.d"

    if [ ! -d "${data_dir}" ] &&
       [ ! -d "${data_dir}.d" ]
    then
      if [ -e "${data_dir}.tgz" ]
      then
        ( cd "${data_dir%/*}/" &&
          tar -zxvf "${data_dir}.tgz" )
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
      cat $sql |${PSQLCMD} -d ${PGDATABASE} ||
        exit 103
    done

  done

done

# end
exit $?
