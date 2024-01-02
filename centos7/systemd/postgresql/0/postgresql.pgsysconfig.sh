#!/bin/bash
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)
# shell opts
set -u -o errtrace -o functrace -o pipefail

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

# postgresql sysconfig
PGSCFG="/etc/sysconfig/postgresql"

# Temporary file
PGSTMP="${TMPDIR:-/tmp}/postgresql.sysconfig.$(date +'%Y%m%d%H%M%S')"

# PG* Vars exports
PG_VAR_EXPORTS=""

# trap
trap \
  "rm -rf ${PGSTMP} &>/dev/null || :" \
  EXIT SIGTERM SIGINT SIGQUIT

# Parse options
while [ $# -gt 0 ]
do
  case "${1:-}" in
  PG*=*)
    [ -n "${1%%=*}" -a -n "${1#*=}" ] &&
    PG_VAR_EXPORTS="${PG_VAR_EXPORTS}${1%%=*}='${1#*=}';export ${1%%=*};" || :
    ;;
  -f*)
    if [ -n "${1##-f}" ]
    then PGSCFG="${1##-f}"
    elif [ -n "${2:-}" ]
    then PGSCFG="${2}"; shift
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: ${THIS} [-f /path/to/sysconfig] [PG*=VALUE ...]

_USAGE_
    exit 1
    ;;
  *)
    ;;
  esac
  shift
done

# Check
[ -r "${PGSCFG}" ] || {
  echo "${THIS}: ERROR: no such file or directory '${PGSCFG}'." 1>&2
  exit 2
}

# Make temp
cat "${PGSCFG}" >|"${PGSTMP}" 2>/dev/null || {
  echo "${THIS}: ERROR: no such file or directory '${PGSCFG}'." 1>&2
  exit 2
}

# PG* Var Exports
if [ -n "${PG_VAR_EXPORTS:-}" ]
then
  eval "${PG_VAR_EXPORTS}" &>/dev/null || {
    echo "${THIS}: ERROR: failed to exports: '${PG_VAR_EXPORTS}'." 1>&2
    exit 22
  }
fi

# Exit state
EXIT_STATE=0

# Main
: "Main" && {

  # PGCTL_START_OPTS
  [ -n "${PGSQLVER:-}" ] && {

    case "${PGSQLVER:-}" in
    8.[0-2]*)
      echo "* PostgreSQL v${PGSQLVER}"
      egrep '^[ ]*PGCTL_START_OPTS=[^ ].*-t[ ]*[0-9]+.*$' "${PGSTMP}" &>/dev/null && {
        ${SED} -ri \
        's/^[ ]*(PGCTL_START_OPTS)=([^ ].*)[ ]+-t[ ]*[0-9]+([^0-9].*)[ ]*$/\1=\2\3/g' \
        "${PGSTMP}"
      }
      ;;
    *)
      ;;
    esac

  } || :

  # Update sysconfig
  : "Update sysconfig" && {
cat - <<_EOF_ >|"${PGSTMP}" 2>/dev/null
# ${PGSCFG}

# PostgreSQL Version
PGSQLVER=${PGSQLVER:-}

# PostgreSQL Super user
PGUSER=${PGUSER:-postgres}

# PostgreSQL Home directory
PGHOME=${PGHOME:-/opt/postgresql}

# PostgreSQL Root directory
PGROOT=${PGROOT:-/opt/postgresql}

# PostgreSQL DATA directory
PGDATA=${PGDATA:-/opt/postgresql/data}

# Port
PGPORT=${PGPORT:-5432}

# PG_CTL: Start Options
PGCTL_START_OPTS="${PGCTL_START_OPTS:--s -w -t 300}"

# PG_CTL: Stop Options
PGCTL_STOP_OPTS="${PGCTL_STOP_OPTS:--s -m fast}"

# PG_CTL: Start Options
PGCTL_RELOAD_OPTS="${PGCTL_RELOAD_OPTS:--s}"

_EOF_
  }

  # Update check
  if [ -s "${PGSTMP}" ]
  then

    echo

    if [ -x "$(type -P diff)" ]
    then
      diff "${PGSCFG}" "${PGSTMP}" &>/dev/null || {

        echo "${THIS}: ${PGSCFG} >>>"

        diff "${PGSCFG}" "${PGSTMP}" || {
          cat "${PGSTMP}" >|"${PGSCFG}"
        } &>/dev/null

      } # diff "${PGSCFG}" "${PGSTMP}"
    else

      echo "${THIS}: ${PGSCFG} >>>"
      cat "${PGSTMP}" >|"${PGSCFG}"
      cat "${PGSCFG}"

    fi

    echo

  else :
  fi

} 1> >(__stdout) 2> >(__stderr) 3>&1
# : "Main" && { ...

# end
exit ${EXIT_STATE:-1}
