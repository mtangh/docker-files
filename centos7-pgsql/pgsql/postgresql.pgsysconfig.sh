#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-pgsysconfig.sh}"
BASE="${THIS%.*}"

# postgresql sysconfig
pgsyscfg="/etc/sysconfig/postgresql"

# Temporary file
pgsystmp="${TMPDIR:-/tmp}/postgresql.sysconfig.$(date +'%Y%m%d%H%M%S')"

# trap
trap \
  "rm -f ${pgsystmp} &>/dev/null || :" \
  EXIT SIGTERM SIGINT SIGQUIT

# Parse options
while [ $# -gt 0 ]
do
  case "$1" in
  PG*=*)
    [ -n "${1%%=*}" -a -n "${1#*=}" ] && {
      eval "${1}"; export "${1%%=*}"
    }
    ;;
  -f*)
    if [ -n "${1##*-f}" ]
    then pgsyscfg="${1##*-f}"
    else shift; pgsyscfg="${1}"
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-f /path/to/sysconfig] [PG*=VALUE ...]

_USAGE_
    exit 1
    ;;
  *)
    ;;
  esac
  shift
done

# Check
[ -r "$pgsyscfg" ] || {
  echo "$THIS: ERROR: no such file or directory '$pgsyscfg'." 1>&2
  exit 2
}

# Make temp
cat "${pgsyscfg}" |>"${pgsystmp}" 2>/dev/null || {
  echo "$THIS: ERROR: no such file or directory '$pgsyscfg'." 1>&2
  exit 3
}

# Each PG* Values
for syscfg_key in PGUSER PGHOME PGROOT PGDATA PGPORT
do

  # New value
  syscfg_val="${!syscfg_key}"
  
  # Old value
  syscfg_old=$(
    cat "${pgsystmp}" |
    sed -nre 's/^[ ]*'"${syscfg_val}"'=([^ ]+)[ ]*$/\1/gp' 2>/dev/null)

  # Ignore
  [ -n "${syscfg_val}" ] ||
    continue
  [ "${syscfg_val}" != "${syscfg_old}" ] ||
    continue

  # Print old, new
  echo "$THIS: '${syscfg_key}' = '${syscfg_old}' to '${syscfg_val}'."

  # Replace
  sed -ri \
    's/^[ ]*'${syscfg_key}'=[^ ]+.*$/'${syscfg_key}'="'${syscfg_val}'"/g' \
    "${pgsystmp}" || continue

  # Additional changes
  case "${syscfg_key}" in
  PGUSER)
    usermod -l "${syscfg_val}" "${syscfg_old:-postgres}"
    groupmod -n "${syscfg_val}" "${syscfg_old:-postgres}"
    ;;
  PGHOME)
    dirowner=$(
      stat -c '%U' "${syscfg_old:-/opt/postgresql}" \
      2>/dev/null; )
    [ -n "${dirowner}" ] && {
      usermod -d "${syscfg_val}" -m "${dirowner}"
    }
    ;;
  PGROOT)
    ( [ -d "${syscfg_val}" ] || {
        mkdir -p "${syscfg_val}"
      }
      cd "${syscfg_val}" && {
        for childdir in $(ls -1d "${syscfg_old:-/opt/postgresql}"/*)
        do
          [ -e "${childdir##*/}" ] &&
          rm -f "${childdir##*/}" &>/dev/null || :
          ln -sf "${childdir}" .
        done
      } 2>/dev/null; )
    ;;
  *)
    ;;
  esac

done

# PGCTL_START_OPTS
[ -n "${PGSQLVAR}" ] && {

  case "${PGSQLVAR}" in
  8.[0-2]*)
    egrep \
    '^[ ]*PGCTL_START_OPTS=[^ ].*-t[ ]*[0-9]+.*$' \
    "$pgsystmp" &>/dev/null && {
      sed -ri \
      's/^[ ]*(PGCTL_START_OPTS)=([^ ].*)-t[ ]*[0-9]+(.*)[ ]*$/\1=\2\3/g' \
      "$pgsystmp"
    }
    ;;
  *)
    ;;
  esac

} || :

# Update check
diff "${pgsyscfg}" "${pgsystmp}" &>/dev/null || {
 
  echo
  echo "$THIS: ${pgsyscfg} >>>"
  
  diff "${pgsyscfg}" "${pgsystmp}" || {
    cat "${pgsystmp}" |>"${pgsyscfg}"
  } &>/dev/null

  echo

} # diff "${pgsyscfg}" "${pgsystmp}"

# end
exit 0
