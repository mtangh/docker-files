#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-pgsysconfig.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# postgresql sysconfig
pgsyscfg="/etc/sysconfig/postgresql"

# Temporary file
pgsystmp="${TMPDIR:-/tmp}/postgresql.sysconfig.$(date +'%Y%m%d%H%M%S')"

# trap
trap \
  "rm -rf ${pgsystmp} &>/dev/null || :" \
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
cat "${pgsyscfg}" >|"${pgsystmp}" 2>/dev/null || {
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
    $SED -nre 's;^[ ]*'${syscfg_key}'=["]*([^ ][^"]*)["]*[ ]*$;\1;gp'; )

  # Ignore
  [ -n "${syscfg_val}" ] ||
    continue
  [ "${syscfg_val}" != "${syscfg_old}" ] ||
    continue

  # Print old, new
  echo "$THIS: '${syscfg_key}' = '${syscfg_old}' to '${syscfg_val}'."

  # Replace
  $SED -ri \
    's;^[ ]*'${syscfg_key}'=[^ ]+.*$;'${syscfg_key}'="'${syscfg_val}'";g' \
    "${pgsystmp}" || continue

  # Additional changes
  case "${syscfg_key}" in
  PGUSER)
    [ -x "$(type -P usermod)" ] && {
      usermod -l "${syscfg_val}" "${syscfg_old:-postgres}" ||
      echo "$THIS: Failed to command 'usermod -l ${syscfg_val} ${syscfg_old:-postgres}'."
      [ -x "$(type -P chpasswd)" ] && {
        echo "${syscfg_val}:${PGPASSWORD:-$syscfg_val}" |chpasswd ||
        echo "$THIS: Failed to command 'echo "${syscfg_val}:*" |chpasswd'."
      }
    }
    [ -x "$(type -P groupmod)" ] && {
      groupmod -n "${syscfg_val}" "${syscfg_old:-postgres}" ||
      echo "$THIS: Failed to command 'groupmod -n ${syscfg_val} ${syscfg_old:-postgres}'." 1>&2
    }
    ;;
  PGHOME)
    dirowner=$(
      stat -c '%U' "${syscfg_old:-/opt/postgresql}" \
      2>/dev/null; )
    [ -x "$(type -P usermod)" ] && {
      usermod -d "${syscfg_val}" -m "${dirowner:-postgres}" ||
      echo "$THIS: Failed to command 'usermod -d ${syscfg_val} -m ${dirowner:-postgres}'." 1>&2
    }
    ;;
  PGROOT)
    ( [ -d "${syscfg_val}" ] || {
        mkdir -p "${syscfg_val}"
      } 2>/dev/null
      cd "${syscfg_val}" &>/dev/null && {
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
[ -n "${PGSQLVER}" ] && {

  case "${PGSQLVER}" in
  8.[0-2]*)
    egrep \
    '^[ ]*PGCTL_START_OPTS=[^ ].*-t[ ]*[0-9]+.*$' \
    "$pgsystmp" &>/dev/null && {
      $SED -ri \
      's/^[ ]*(PGCTL_START_OPTS)=([^ ].*)[ ]+-t[ ]*[0-9]+([^0-9].*)[ ]*$/\1=\2\3/g' \
      "$pgsystmp"
    }
    ;;
  *)
    ;;
  esac

} || :

# Update check
[ -s "${pgsystmp}" ] && {

  diff "${pgsyscfg}" "${pgsystmp}" &>/dev/null || {

    echo
    echo "$THIS: ${pgsyscfg} >>>"

    diff "${pgsyscfg}" "${pgsystmp}" || {
      cat "${pgsystmp}" >|"${pgsyscfg}"
    } &>/dev/null

    echo

  } # diff "${pgsyscfg}" "${pgsystmp}"

}

# end
exit 0
