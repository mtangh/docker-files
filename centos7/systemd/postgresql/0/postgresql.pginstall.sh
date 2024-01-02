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

# cleanup
__pginstall_cleanup() {
  : && {
    [ -d "/root/.cpan" ] && rm -rf /root/.cpan 
  } &>/dev/null
  return 0
}

# PG sysconfig
PGSCFG="/etc/sysconfig/postgresql"

# PG Work dir
PG_WORKDIR="${PG_WORKDIR:-/tmp/pginstall}"

# PG* Vars exports
PG_VAR_EXPORTS=""

# trap
trap \
  "__pginstall_cleanup" \
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
  -w*)
    if [ -n "${1##-w}" ]
    then PG_WORKDIR="${1##-w}"
    elif [ -n "${2:-}" ]
    then PG_WORKDIR="${2}"; shift
    fi
    ;;
  -*)
cat - <<_USAGE_
Usage: ${THIS} [-w /path/to/workdir] [PG*=VALUE ...]

_USAGE_
    exit 1
    ;;
  *)
    ;;
  esac
  shift
done

# Load the sysconfig/postgresql
[ -r "${PGSCFG:-X}" ] &&
. "${PGSCFG:-X}" &>/dev/null || {
  echo "${THIS}: ERROR: Failed to load sysconfig '${PGSCFG}'." 1>&2
  exit 2
}

# Check
[ -z "${PGSQLVER:-}" ] && {
  echo "${THIS}: ERROR: 'PGSQLVER' is not set !!" 1>&2
  exit 1
} || :

# PG* Var Exports
if [ -n "${PG_VAR_EXPORTS:-}" ]
then
  eval "${PG_VAR_EXPORTS}" &>/dev/null || {
    echo "${THIS}: ERROR: failed to exports: '${PG_VAR_EXPORTS}'." 1>&2
    exit 22
  }
fi

# Check PG_WORKDIR
[ -d "${PG_WORKDIR}" ] || {
  mkdir -p "${PG_WORKDIR}"
} &>/dev/null || :

# Change DIR
cd "${PG_WORKDIR:-X}" &>/dev/null || {
  echo "${THIS}: ERROR: no such file or directory: PG_WORKDIR='${PG_WORKDIR:-?}'." 1>&2
  exit 2
}

# PG Tools Dir.
pgsqldir="/usr/local/postgresql"

# Exit state
EXIT_STATE=0

# Main
: "Main" && {

  # Xtrace FD
  BASH_XTRACEFD=3
  export BASH_XTRACEFD

  # PGUSER
  PGUSER="${PGUSER:-postgres}"

  # PGHOME
  PGHOME="${PGHOME:-/opt/postgresql}"

  # PGROOT
  PGROOT="${PGROOT:-/opt/postgresql}"

  # PGDATA
  PGDATA="${PGDATA:-${PGHOME}/data}"

  # PGUSER UID
  PG_UID="${PG_UID:-26}"

  # PGARCHLOGDIR
  PGARCHLOGDIR="${PGARCHLOGDIR:-${PGHOME}/archivelogs}"

  # PGPASSWORD
  [ -n "${PGPASSWORD:-}" ] || {
    if [ -r "/run/secrets/PGPASSWORD" ]
    then PGPASSWORD=$(cat /run/secrets/PGPASSWORD 2>/dev/null)
    else PGPASSWORD=""
    fi
  }

  # Print
  : "Start" && {

cat <<_EOF_
Start '${CDIR}/${THIS}'.
# CurrentDir: $(pwd)
# PG_WORKDIR: ${PG_WORKDIR}
#
# [Version]
# PGSQLVER=[${PGSQLVER:-}]
# PGTAPVER=[${PGTAPVER:-}]
#
# [PG*-Variables]
# PGUSER=${PGUSER}
# PG_UID=${PG_UID}
# PGHOME=${PGHOME}
# PGROOT=${PGROOT}
# PGDATA=${PGDATA}
# PGARCHLOGDIR=${PGARCHLOGDIR}
#
_EOF_

  }

  # xtrace on
  set -x

  # User and group
  echo "PG User and group" && {

    egrep "^${PGUSER}:" /etc/group &>/dev/null || {
      groupadd -g "${PG_UID}" "${PGUSER}" &&
      echo "Group '${PGUSER}' added."; } &&
    egrep "^${PGUSER}:" /etc/passwd &>/dev/null || {
      useradd -u "${PG_UID}" -g "${PGUSER}" -d "${PGHOME}" -m "${PGUSER}" &&
      echo "User '${PGUSER}' added."; } && {
        set +x
        echo "Set password for user '${PGUSER}'." &&
        echo "${PGUSER}:${PGPASSWORD:-$PGUSER}" |
        chpasswd
        set -x
      }

  } &&
  echo "SetUp ${PGHOME:-}" && {
  
    [ -d "${PGHOME}" ] || {
      mkdir -p "${PGHOME}"
    } &&
    [ -d "${PGHOME}" ] && {
      chown -v "${PGUSER}:${PGUSER}" "${PGHOME}" &&
      chmod -v 2750 "${PGHOME}"
    } &&
    : "SetUp postgres's .bashrc" && {

      egrep /etc/sysconfig/postgresql "${PGHOME}/.bashrc" &>/dev/null || {

cat <<_EOF_ 1>>"${PGHOME}/.bashrc"

# For PostgreSQL
if [ -r "/etc/sysconfig/postgresql" ]
then
  . /etc/sysconfig/postgresql
  export PGUSER PGHOME PGROOT PGDATA PGPORT
fi
if [ -z "$(type -P psql)" -a \
     -x "${PGROOT:-X}/bin/psql" ]
then
  PATH="${PGROOT}/bin:${PATH}"
  export PATH
fi

_EOF_

      }
    } # : "SetUp postgres's .bashrc"
  
  } ||
  EXIT_STATE=$?
  
  # PostgreSQL
  if [ ${EXIT_STATE:-1} -eq 0 ] &&
     [ -n "${PGSQLVER:-}" ]
  then

    # Print
cat <<_EOF_
# --------------------------------------
# PostgreSQL v${PGSQLVER}
# $(pwd)
# --------------------------------------
_EOF_

    # PostgreSQL Name
    PGSQLSRC="${PGSQLSRC:-postgresql-${PGSQLVER}}"

    # PostgreSQL Source URL
    PGSRCURL="${PGSRCURL:-https://ftp.postgresql.org/pub/source/v${PGSQLVER}/${PGSQLSRC}.tar.gz}"

    # PostgreSQL Install Prefix
    PGPREFIX="${PGPREFIX:-${PGROOT%/*}/${PGSQLSRC}}"

    # Print
cat <<_EOF_
PGSQLSRC=${PGSQLSRC}
PGSRCURL=${PGSRCURL}
PGPREFIX=${PGPREFIX}
_EOF_

    # Configure options
    case "${PG_CONFIGURE_OPTS:-}" in
    *--prefix=*)
      PG_CONFIGURE_OPTS=$(
      echo "${PG_CONFIGURE_OPTS}" |${SED} -re \
      's/^(.*--prefix=)[^=[:space:]]+(.*)$/\1'"${PGPREFIX}"'\2/g' \
      2>/dev/null; )
      ;;
    *)
      PG_CONFIGURE_OPTS="--prefix=${PGPREFIX}${PG_CONFIGURE_OPTS:+ $PG_CONFIGURE_OPTS}"
      ;;
    esac

    # Install GCC
    if [ -n "${PG_GCC_PKG:-}" ]
    then

      echo "Installing GCC=${PG_GCC_PKG}" &&
      ${YUM} update &&
      ${YUM} install "${PG_GCC_CMD}" &&
      [ -n "${PG_GCC_CMD}" -a -x "${PG_GCC_CMD}" ] && {
        CC="${PG_GCC_CMD}"; export CC; } &&
      echo "Install successfuly: GCC=${PG_GCC_PKG}"
  
    else :
    fi

    echo "Download, make, make install" && {

      : "Download" && {
        curl -sL -o - "${PGSRCURL}" |
        tar -zpxvf -
      } &&
      : "Make" && {
        pushd "${PGSQLSRC}" &&
        echo ">>> ./configure ${PG_CONFIGURE_OPTS}" &&
        ./configure ${PG_CONFIGURE_OPTS} &&
        echo ">>> make and make install" &&
        make &&
        make install &&
        echo ">>> make and make install (contrib)" &&
        cd ./contrib && {
          make &&
          make install
        } &&
        popd
      }

    } &&
    echo "Construction PGROOT(${PGROOT})" && {

      # Symlink dirs
      [ -d "${PGROOT}" ] || {
        mkdir -p "${PGROOT}"
      } &&
      [ -d "${PGROOT}" ] && {
        chown -v "${PGUSER}:${PGUSER}" "${PGROOT}" &&
        chmod -v 2750 "${PGROOT}"
      } &&
      pushd "${PGROOT}" && {

        rm -f "${PGROOT}-latest" &>/dev/null || :

        ln -sf "${PGPREFIX}" "${PGROOT}-latest" && {
          for _dirpath in $(ls -1d "${PGROOT}-latest"/* 2>/dev/null)
          do

            _dirname="${_dirpath##*/}"
            [ -e "${PGROOT}/${_dirname}" ] && {
              rm -rf "${PGROOT}/${_dirname}"
            } || :
            ln -sfv "${_dirpath}" ${PGROOT}/${_dirname} &&
            chown -v -h "${PGUSER}:${PGUSER}" "${PGROOT}/${_dirname}" &&
            echo "Symlink '${_dirpath}' to '${PGROOT}/${_dirname}'."
          
          done
        }

      } && popd

    } &&
    echo "Initialize the database: Dir=(${PGROOT})." && {

      [ -d "${PGDATA}" ] || {
        mkdir -pv "${PGDATA}"
      } &&
      [ -d "${PGDATA}" ] && {
        chown -v "${PGUSER}:${PGUSER}" "${PGDATA}" &&
        chmod -v 2750 "${PGDATA}"
      } &&
      su - "${PGUSER}" -c \
      "LANG= ${PGROOT}/bin/initdb ${PG_INITDB_OPTS:--E UTF-8 --locale=C} ${PGDATA}" &&
      [ -f "${PGDATA}/PG_VERSION" ]

    } &&
    echo "Initialize the database: Dir=(${PGROOT})." && {

      # PGDATA, Archivelogs
      pushd "${PGHOME}" && {
        for _dirpath in \
          "${PGDATA:-$PGHOME}/pg_log" \
          "${PGARCHLOGDIR:-}"
        do
          [ -n "${_dirpath}" ] ||
            continue
          [ -d "${_dirpath}" ] || {
            mkdir -p "${_dirpath}"
          } &&
          [ -d "${_dirpath}" ] && {
            chown -v "${PGUSER}:${PGUSER}" "${_dirpath}" &&
            chmod -v 2750 "${_dirpath}"
          } &&
          echo "Mkdir '${_dirpath}'."
        done
      } && popd

    } &&
    echo "Add to the service" && {

      if [ -x "$(type -P systemctl)" ]
      then
        systemctl enable postgresql.service 2>&1 || :
      elif [ -x "$(type -P chkconfig)" ]
      then
        chkconfig --add postgresql &&
        chkconfig --levels 2345 postgresql on || :
      fi

    } ||
    EXIT_STATE=$?

    # Print
cat <<_EOF_
# --------------------------------------
_EOF_

  else :
  fi 1> >(__stdout "PGSQL")

  # pgTap and prove
  if [ ${EXIT_STATE:-1} -eq 0 ] &&
     [ -n "${PGTAPVER:-}" ]
  then

    # Print
cat <<_EOF_
# --------------------------------------
# pgTAP v${PGTAPVER}
# $(pwd)
# --------------------------------------
_EOF_

    # pgTAP Name
    PGTAPSRC="${PGTAPSRC:-pgtap-${PGTAPVER}}"

    # pgTAP Source URL
    PGTAPURL="${PGTAPURL:-http://api.pgxn.org/dist/pgtap/${PGTAPVER}/${PGTAPSRC}.zip}"

    # Print
cat <<_EOF_
PGTAPSRC=${PGTAPSRC}
PGTAPURL=${PGTAPURL}
_EOF_

    # Check
    [ -x "${PGROOT:-}/bin/pg_config" ] || {
      echo "command 'pg_config' not found." 1>&2
    } &&
    [ -x "$(type -P pg_config)" ] || {
      PATH="${PGROOT:-}/bin:${PATH}"
      export PATH
    } &&
    echo "pgTAP and pg_prove needs." && {

      # pgTAP needs
      pgtapneeds=""

      [ -x "$(type -P unzip)" ] || {
        echo "pgTAP(and pg_prove) need 'unzip' ... Command not found."
        pgtapneeds="${pgtapneeds}${pgtapneeds:+ }unzip"
      } &&
      [ -x "$(type -P cpan)" ] || {
        echo "pgTAP(and pg_prove) need 'CPAN' ... Command not found."
        pgtapneeds="${pgtapneeds}${pgtapneeds:+ }perl-CPAN"
      } &&
      [ -z "${pgtapneeds}" ] || {
        # Install Unzip and or CPAN (If needed)
        echo "Installing ${pgtapneeds}." &&
        ${YUM} update &&
        ${YUM} install ${pgtapneeds} &&
        echo "Install successfuly: ${pgtapneeds}"
      }

    } &&
    echo "pgTAP" && {

      # Download, make, make install
      curl -sL -o "${PGTAPSRC}.zip" "${PGTAPURL}" &&
      unzip "${PGTAPSRC}.zip" && {
        pushd "${PGTAPSRC}" && {
          make &&
          make install
        } && popd
      }

    } &&
    echo "pg_prove" && {

      export PERL_MM_OPT="install_base"
      export PERL_AUTOINSTALL="--defaultdeps"
      { cpan < <(echo;echo;echo exit) || :; }
      cpan -i Module::Build &&
      cpan -i TAP::Parser::SourceHandler::pgTAP

    } &&
    echo "Uninstall Unzip and/or CPAN" && {

      [ -n "${pgtapneeds}" ] || {
        ${YUM} remove ${pgtapneeds} &&
        echo "Uninstall successfuly; ${pgtapneeds}."
      }

    } ||
    EXIT_STATE=$?

    # Print
cat <<_EOF_
# --------------------------------------
_EOF_

  else :
  fi 1> >(__stdout "PGTAP")

  # Uninstall GCC
  if [ -n "${PG_GCC_PKG:-}" ]
  then

    # Uninstall GCC
    echo "Uninstalling GCC=${PG_GCC_PKG}" &&
    ${YUM} update &&
    ${YUM} remove "${PG_GCC_PKG}" &&
    echo "Uninstall successfuly: GCC=${PG_GCC_PKG}"

  else :
  fi

  # xtrace off
  set +x

  # Print
  : "End" && {
cat <<_EOF_
Exit '${CDIR}/${THIS}' [${EXIT_STATE:-1}].
_EOF_
  }

} 1> >(__stdout) 2> >(__stderr) 3>&1
# : "Main" && { ...

# Wait
__wait $! &>/dev/null || :

# end
exit ${EXIT_STATE:-1}
