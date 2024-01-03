#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)

[ -x "$(type -P psql)" ] || {
  echo "command 'psql' not found." 1>&2
  exit 1
}

PGDATA="${PGDATA:-/var/lib/pgsql/data}"
PGPORT="${PGPORT:-5432}"

: "Initailize database" && {

  su -m postgres -c \
  "initdb --pgdata=${PGDATA} ${PG_INITDB_OPTS:--E UTF-8 --locale=C}"

} &&
: "Update data/*.conf" && {

  pgsqlcnf="${PGDATA}/postgresql.conf"
  pghbacnf="${PGDATA}/pg_hba.conf"
  pgidtcnf="${PGDATA}/pg_ident.conf"

  for _cnf in "${pgsqlcnf}" "${pghbacnf}" "${pgidtcnf}"
  do
    [ -e "${_cnf}.ORIG" ] || {
      cp -pf "${_cnf}"{,.ORIG} 
    } &&
    if [ -s "./${_cnf##*/}" ]
    then
      cat "./${_cnf##*/}" 1>"${pgsqlcnf}" 2>&1
    else
      case "${_cnf}" in
      */postgresql.conf)
        cat "${_cnf}" |sed -r \
        -e '/^#listen_addresses/i listen_addresses = '"'*'"'' \
        -e '/^#port[[:space:]]+=[[:space:]]+5432/i port = '"${PGPORT}"'' \
        1>"${_cnf}.tmp" &&
        mv -fv "${_cnf}.tmp" "${_cnf}"
        ;;
      esac
    fi 
  done

} &&
: "Done.";

exit $?