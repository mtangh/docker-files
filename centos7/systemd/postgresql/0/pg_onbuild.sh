#!/bin/bash
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)
# shell opts
set -ux -o errtrace -o functrace -o pipefail

# Work dir.
work_dir=$(pwd)

# Bash
bash_cmd="${bash_cmd:-/bin/bash -ux -o errtrace -o functrace -o pipefail}"

# PG Tools Dir.
pgsqldir="/usr/local/postgresql"

# Package needs
pkgneeds=""

# YUM or DNF
YUM=""
if [ -x "$(type -P dnf)" ]
then YUM="dnf -v -y"
elif [ -x "$(type -P yum)" ]
then YUM="yum -v -y"
fi

# Run
: "${THIS}: Update sysconfig" && {

  ${bash_cmd} \
  "${pgsqldir}/bin/pgsysconfig.sh" -f "/etc/sysconfig/postgresql" &&
  . /etc/sysconfig/postgresql &&
  [ -n "${PGUSER}" -a -n "${PGROOT}" -a -n "${PGHOME}" ]

} &&
: "${THIS}: Install packages for PostgreSQL (and pgTAP)" && {

  if [ -n "${YUM:-}" ]
  then

    for _pkg in diffutils which tar unzip make patch gcc readline-devel zlib-devel
    do
      rpm -qi "${_pkg}" &>/dev/null ||
      pkgneeds="${pkgneeds}${pkgneeds:+ }${_pkg}" || :
    done
    [ -n "${pkgneeds}" ] && {
      ${YUM} update &&
      ${YUM} install ${pkgneeds}
    }

  else :
  fi

} &&
: "${THIS}: Install postgresql and pgTAP, pg_prove" && {

  ${bash_cmd} \
  "${pgsqldir}/bin/pginstall.sh" -w "${work_dir}"

} && \
: "${THIS}: Setup default config" && { \

  for _cnf in ./*.conf
  do

    [ -s "${PGDATA}/${_cnf}" -a \
    ! -e "${PGDATA}/${_cnf}.ORIG" ] &&
      cp -pf "${PGDATA}/${_cnf}"{,.ORIG} || :

    : && { 
      mv -f "${_cnf}" "${PGDATA}/${_cnf}" &&
      chown "${PGUSER}:${PGUSER}" "${PGDATA}/${_cnf}" &&
      chmod 0644 "${PGDATA}/${_cnf}"
    } ||
    break

  done

} &&
: "${THIS}: Uninstall packages." && {

  if [ -n "${YUM:-}" ]
  then

    ${YUM} remove ${pkgneeds} || :
    ${YUM} clean all || :

  else :
  fi

} &&
: "${THIS}: Done."

exit $?
