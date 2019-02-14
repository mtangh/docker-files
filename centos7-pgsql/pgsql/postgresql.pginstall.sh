#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-pginstall.sh}"
BASE="${THIS%.*}"

# postgresql sysconfig
pgsyscfg="/etc/sysconfig/postgresql"

# Load sysconfig
. "${pgsyscfg}" &>/dev/null || {
  echo "$THIS: ERROR: no such file or directory '$pgsyscfg'." 1>&2
  exit 127
}

# trap
trap
  "rm -rf ${PG_WORKDIR} &>/dev/null || :"
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
  -w*)
    if [ -n "${1##*-f}" ]
    then PG_WORKDIR="${1##*-f}"
    else shift; PG_WORKDIR="${1}"
    fi
    ;;
  -*)
    cat <<_USAGE_
Usage: $THIS [-w /path/to/workdir] [PG*=VALUE ...]

_USAGE_
    exit 1
    ;;
  *)
    ;;
  esac
  shift
done

# Check
[ -z "$PGSQLVER" -a -z "${PGTAPVER}" ] && {
  echo "$THIS: ERROR: 'PGSQLVER' and 'PGTAPVER' is not set !!" 1>&2
  exit 70
} || :

# PG Work dir
PG_WORKDIR="${PG_WORKDIR:-/tmp/workdir}"

# Check PG_WORKDIR
[ -d "${PG_WORKDIR}" ] || {
  mkdir -p "${PG_WORKDIR}"
} &>/dev/null

# Change DIR
cd "${PG_WORKDIR}" &>/dev/null || {
  echo "$THIS: ERROR: no such file or directory: PG_WORKDIR='${PG_WORKDIR}'." 1>&2
  exit 72
}

# PGUSER
PGUSER="${PGUSER:-postgres}"

# PGHOME
PGHOME="${PGHOME:-/opt/postgresql}"

# PGROOT
PGROOT="${PGROOT:-/opt/postgresql}"

# PGDATA
PGDATA="${PGDATA:-$PGHOME/data}"

# PGARCHLOGDIR
PGARCHLOGDIR="${PGARCHLOGDIR:-$PGHOME/archivelogs}"

# MKDIR PGHOME
[ -d "${PGHOME}" ] || {
  mkdir -p "${PGHOME}" &&
  chown "${PGUSER}:${PGUSER}" "${PGHOME}" &&
  chmod 2750 "${PGHOME}"
} &>/dev/null

# MKDIR PGROOT
[ -d "${PGROOT}" ] || {
  mkdir -p "${PGROOT}" &&
  chown "${PGUSER}:${PGUSER}" "${PGROOT}" &&
  chmod 2755 "${PGROOT}"
} &>/dev/null

# Install PostgreSQL
[ -z "${PGSQLVER}" ] || {

  # Print
  cat <<_EOF_
$THIS:
$THIS: PostgreSQL v$PGSQLVER
$THIS:
_EOF_

  # PostgreSQL Name
  PGSQLSRC="${PGSQLSRC:-postgresql-$PGSQLVER}"

  # PostgreSQL Source URL
  PGSRCURL="${PGSRCURL:-https://ftp.postgresql.org/pub/source/v$PGSQLVER/$PGSQLSRC.tar.gz}"

  # PostgreSQL Install Prefix
  PGSRCDIR="${PGSRCDIR:-${PGROOT%/*}-$PGSQLVER}"

  # Print
  cat <<_EOF_
$THIS: PGSQLSRC=$PGSQLSRC
$THIS: PGSRCURL=$PGSRCURL
$THIS: PGSRCDIR=$PGSRCDIR
_EOF_

  # Configure options
  case "${PG_CONFIGURE_OPTS}" in
  *--prefix=*)
    ;;
  *)
    PG_CONFIGURE_OPTS="--prefix=${PGSRCDIR}${PG_CONFIGURE_OPTS:+ $PG_CONFIGURE_OPTS}"
    ;;
  esac

  # GCC
  ( [ -n "${PG_GCC_PKG}" ] && {
      echo "$THIS: GCC=${PG_GCC_PKG}"
      yum -y update &&
      yum -y install "${PG_GCC_PKG}" &&
      yum -y clean all
    }; ) || exit 100

  # Download, make, make install
  curl -sL -o - "${PGSRCURL}" |
  tar -zpxvf - &&
  ( cd "${PGSQLSRC}" && {

      [ -n "${PG_GCC_CMD}" ] &&
      [ -x "${PG_GCC_CMD}" ] && {
        CC="${PG_GCC_CMD}"
        export CC
      } || :

      echo "$THIS: ./configure ${PG_CONFIGURE_OPTS}"

      ./configure ${PG_CONFIGURE_OPTS} &&
      make &&
      make install &&
      cd ./contrib && {
        make &&
        make install
      }

    }; ) || exit 101

  # Symlink dirs
  ( cd "${PGROOT}" && {

      rm -rf "${PGROOT}-latest" &>/dev/null || :

      ln -sf "${PGSRCDIR}" "${PGROOT}-latest" && {

        for dir in $(ls -1d "${PGROOT}-latest"/* 2>/dev/null)
        do
          [ -e "${dir}" ] && rm -rf "${dir}"
          ln -sf "${PGROOT}-latest/${dir}" . &&
          chown -h "${PGUSER}:${PGUSER}" "${dir}" &&
          echo "$THIS: symlink '${PGROOT}-latest/${dir}' to '${PGROOT}/${dir}'."
        done

      }

    }; ) || exit 102

  # PGDATA, Archivelogs
  ( cd "${PGHOME}" && {

      for dir in "${PGDATA}" "${PGARCHLOGDIR}"
      do
        [ -d "${dir}" ] || {
          mkdir -p "${dir}"
        } &&
        chown "${PGUSER}:${PGUSER}" "${dir}" &&
        chmod 2750 "${dir}" &&
        echo "$THIS: mkdir '${dir}'."
      done

    }; ) || exit 103

} # [ -z "${PGSQLVER}" ]

# Install pgtap
[ -z "${PGTAPVER}" ] || {

  # Check
  [ -x "${PGROOT}/bin/psql" ] || {
    echo "$THIS: ERROR: Command 'psql' not found." 1>&2
    exit 110
  }

  # Print
  cat <<_EOF_
$THIS:
$THIS: pgTAP v$PGTAPVER
$THIS:
_EOF_

  # pgTAP Name
  PGTAPSRC="${PGTAPSRC:-pgtap-$PGTAPVER}"

  # pgTAP Source URL
  PGTAPURL="${PGTAPURL:-http://api.pgxn.org/dist/pgtap/$PGTAPVER/$PGTAPSRC.zip}"

  # Print
  cat <<_EOF_
$THIS: PGTAPSRC=$PGTAPSRC
$THIS: PGTAPURL=$PGTAPURL
_EOF_

  # Install CPAN
  ( : && {
      yum -y update &&
      yum -y install unzip perl perl-CPAN perl-parent &&
      yum -y clean all
    }; ) || exit 111

  # Download, make,make install, pg_prove install
  curl -sL -o "${PGTAPSRC}.zip" "${PGTAPURL}" &&
  unzip "${PGTAPSRC}.zip" &&
  ( cd "${PGTAPSRC}" && {
      make &&
      make install &&
      rm -rf "./${PGTAPSRC}"* &>/dev/null
    }; ) || exit 112

  # Install pg_prove
  ( : && {
      export PERL_MM_OPT="install_base"
      export PERL_AUTOINSTALL="--defaultdeps"
      cpan -i Module::Build &&
      cpan -i TAP::Parser::SourceHandler::pgTAP &&
      rm -rf /root/.cpan &>/dev/null
    }; ) || exit 113

} # [ -z "${PGTAPVER}" ]

# end
exit 0
