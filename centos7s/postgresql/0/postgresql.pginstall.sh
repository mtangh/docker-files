#!/bin/bash
THIS="${0##*/}"
CDIR=$([ -n "${0%/*}" ] && cd "${0%/*}" 2>/dev/null; pwd)

# Name
THIS="${THIS:-pginstall.sh}"
BASE="${THIS%.*}"

# awk
AWK="${AWK:-$(type -P gawk)}"
AWK="${AWK:-$(type -P awk)}"

# sed
SED="${SED:-$(type -P gsed)}"
SED="${SED:-$(type -P sed)}"

# postgresql sysconfig
pgsyscfg="/etc/sysconfig/postgresql"

# Load sysconfig
. "${pgsyscfg}" &>/dev/null || {
  echo "$THIS: ERROR: no such file or directory '$pgsyscfg'." 1>&2
  exit 127
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

# cleanup
__pginstall_cleanup() {
  : && {
    [ -d "${PG_WORKSIR}" ] && rm -rf "${PG_WORKSIR}"/*
    [ -d "/root/.cpan" ] && rm -rf /root/.cpan 
  } &>/dev/null
  return 0
}

# trap
trap \
  "__pginstall_cleanup" \
  EXIT SIGTERM SIGINT SIGQUIT

# Parse options
while [ $# -gt 0 ]
do
  case "${1}" in
  PG*=*)
    [ -n "${1%%=*}" -a -n "${1#*=}" ] && {
      eval "${1}"; export "${1%%=*}"
    }
    ;;
  -w*)
    if [ -n "${1##*-w}" ]
    then PG_WORKDIR="${1##*-w}"
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
PG_WORKDIR="${PG_WORKDIR:-/tmp/pginstall}"

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

# Print
: && {
cat <<_EOF_
Start '${CDIR}/${THIS}'.

PGUSER=$PGUSER
PGHOME=$PGHOME
PGROOT=$PGROOT
PGDATA=$PGDATA

_EOF_
} |
__stdout

# Install PostgreSQL
[ -z "${PGSQLVER}" ] || {

  # Print
  cat <<_EOF_
# --------------------------------------
# PostgreSQL v$PGSQLVER
# $(pwd)
# --------------------------------------
_EOF_

  # PostgreSQL Name
  PGSQLSRC="${PGSQLSRC:-postgresql-$PGSQLVER}"

  # PostgreSQL Source URL
  PGSRCURL="${PGSRCURL:-https://ftp.postgresql.org/pub/source/v$PGSQLVER/$PGSQLSRC.tar.gz}"

  # PostgreSQL Install Prefix
  PGSRCDIR="${PGSRCDIR:-${PGROOT%/*}/$PGSQLSRC}"

  # Print
  cat <<_EOF_
PGSQLSRC=$PGSQLSRC
PGSRCURL=$PGSRCURL
PGSRCDIR=$PGSRCDIR
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
  [ -n "${PG_GCC_PKG}" ] && {
    echo "GCC=${PG_GCC_PKG}"
    yum -y update &&
    yum -y install "${PG_GCC_PKG}" &&
    yum -y clean all || exit 100
  } || :

  # Download, make, make install
  curl -sL -o - "${PGSRCURL}" |
  tar -zpxvf - &&
  ( pushd "${PGSQLSRC}" && {

      [ -n "${PG_GCC_CMD}" ] &&
      [ -x "${PG_GCC_CMD}" ] && {
        CC="${PG_GCC_CMD}"
        export CC
      } || :

      echo "./configure ${PG_CONFIGURE_OPTS}"

      ./configure ${PG_CONFIGURE_OPTS} &&
      make &&
      make install &&
      cd ./contrib && {
        make &&
        make install
      }

    } &&
    popd; ) || exit 101

  # Symlink dirs
  ( pushd "${PGROOT}" && {

      rm -rf "${PGROOT}-latest" &>/dev/null || :

      ln -sf "${PGSRCDIR}" "${PGROOT}-latest" && {

        for dirpath in $(ls -1d "${PGROOT}-latest"/* 2>/dev/null)
        do
          dirname="${dirpath##*/}"
          [ -e "${PGROOT}/${dirname}" ] && {
            rm -f "${PGROOT}/${dirname}"
          } || :
          ln -sf "${dirpath}" ${PGROOT}/${dirname} &&
          chown -h "${PGUSER}:${PGUSER}" "${PGROOT}/${dirname}" &&
          echo "$THIS: symlink '${dirpath}' to '${PGROOT}/${dirname}'."
        done

      }

    } &&
    popd; ) || exit 102

  # PGDATA, Archivelogs
  ( pushd "${PGHOME}" && {

      for dirpath in "${PGDATA}" "${PGARCHLOGDIR}"
      do
        [ -d "${dirpath}" ] || {
          mkdir -p "${dirpath}"
        } &&
        chown "${PGUSER}:${PGUSER}" "${dirpath}" &&
        chmod 2750 "${dirpath}" &&
        echo "$THIS: Mkdir '${dirpath}'."
      done

    } &&
    popd; ) || exit 103

  # Print
  cat <<_EOF_
# --------------------------------------
_EOF_

} |
__stdout PGSQL
# [ -z "${PGSQLVER}" ]

# Check
[ -z "${PGTAPVER}" ] || {
  # Check
  [ -x "${PGROOT}/bin/pg_config" ] || {
    echo "$THIS: ERROR: command 'pg_config' not found." 1>&2
    exit 110
  }
  # Path
  [ -x "$(type -P pg_config)" ] || {
    PATH="${PGROOT}/bin:${PATH}"
    export PATH
  }
}

# Install pgtap
[ -z "${PGTAPVER}" ] || {

  # Print
  cat <<_EOF_
# --------------------------------------
# pgTAP v$PGTAPVER
# $(pwd)
# --------------------------------------
_EOF_

  # pgTAP Name
  PGTAPSRC="${PGTAPSRC:-pgtap-$PGTAPVER}"

  # pgTAP Source URL
  PGTAPURL="${PGTAPURL:-http://api.pgxn.org/dist/pgtap/$PGTAPVER/$PGTAPSRC.zip}"

  # Print
  cat <<_EOF_
PGTAPSRC=$PGTAPSRC
PGTAPURL=$PGTAPURL
_EOF_

  # Install CPAN
  [ -x "$(type -P cpan)" ] || {
  
    # Print
    echo "CPAN not found."

    yum -y update &&
    yum -y install unzip perl perl-CPAN perl-parent &&
    yum -y clean all &&
    echo "CPAN install successfuly."

  } || exit 111

  # Print
  echo "# pgTAP"
  
  # Download, make, make install
  curl -sL -o "${PGTAPSRC}.zip" "${PGTAPURL}" &&
  unzip "${PGTAPSRC}.zip" &&
  ( pushd "${PGTAPSRC}" && {
  
      make &&
      make install

    } &&
    popd; ) || exit 112

  # Print
  echo "# pg_prove"

  # Install pg_prove
  ( : && {

      export PERL_MM_OPT="install_base"
      export PERL_AUTOINSTALL="--defaultdeps"
      cpan -i Module::Build &&
      cpan -i TAP::Parser::SourceHandler::pgTAP

    }; ) || exit 113


  # Print
  cat <<_EOF_
# --------------------------------------
_EOF_

} |
__stdout PGTAP
# [ -z "${PGTAPVER}" ]

# Print
: && {
cat <<_EOF_
Exit '${CDIR}/${THIS}'.
_EOF_
} |
__stdout

# end
exit 0
