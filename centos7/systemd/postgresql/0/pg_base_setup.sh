#!/bin/bash
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}" 2>/dev/null; pwd)
# shell opts
set -ux -o errtrace -o functrace -o pipefail

work_dir=$(pwd)
pgsqldir="/usr/local/postgresql"

# YUM or DNF
YUM=""
if [ -x "$(type -P dnf)" ]
then YUM="dnf -v -y"
elif [ -x "$(type -P yum)" ]
then YUM="yum -v -y"
fi

: "${THIS}: SetUp sysconfig" && {

  [ -s "${work_dir}/postgresql.sysconfig" ] && {
    mv -fv \
      "${work_dir}/postgresql.sysconfig" \
      /etc/sysconfig/postgresql
  } &&
  [ -s "/etc/sysconfig/postgresql" ] && {
    chown -v root:root /etc/sysconfig/postgresql &&
    chmod -v 0644 /etc/sysconfig/postgresql
  } &&
  [ -s "/etc/sysconfig/postgresql" ] && {
    . /etc/sysconfig/postgresql
    [ -n "${PGUSER:-}" -a -n "${PGROOT:-}" -a -n "${PGHOME:-}" ]
  }

} &&
: "${THIS}: Install systemd service file or sysvinit script file." && {

  if [ -x "$(type -P systemctl)" ]
  then

    etcsysdsvc_dir="/etc/systemd/system"
    etcsysdsvc_ret=0

    [ -d "${etcsysdsvc_dir}" ] || {
      mkdir -pv "${etcsysdsvc_dir}"
    } &&
    [ -d "${etcsysdsvc_dir}" ] && {
      chown -v root:root "${etcsysdsvc_dir}" &&
      chmod -v 0644 "${etcsysdsvc_dir}"
    } &&
    [ -d "${etcsysdsvc_dir}" ] && {
      for syssvcfile in $( ls -1 \
        "${work_dir}"/postgresql*.{service,timer} \
        2>/dev/null || :;)
      do

        syssvcname="${syssvcfile##*/}"

        [ -s "${syssvcfile}" ] && {
          mv -fv "${syssvcfile}" "${etcsysdsvc_dir}/${syssvcname}" &&
          chown -v root:root "${etcsysdsvc_dir}/${syssvcname}" &&
          chmod -v 0644 "${etcsysdsvc_dir}/${syssvcname}" &&
          case "${syssvcname}" in
          *.timer)
            systemctl enable "${syssvcname}"
            ;;
          *)
            ;;
          esac
        } ||
        etcsysdsvc_ret=$?

      done &&
      [ ${etcsysdsvc_ret:-1} -eq 0 ]
    }

  else

    etcinitd_dir="/etc/init.d"
    etccrond_dir="/etc/cron.d"
    etcinitd_ret=0

    if [ -n "${YUM:-}" ]
    then
      rpm -qi cron &>/dev/null || {
        ${YUM} update &&
        ${YUM} install cron
      } || :
    fi

    [ -d "${etcinitd_dir}" ] || {
      [ -d "/etc/rc.d/init.d" ] || {
        mkdir -pv /etc/rc.d/init.d
      } &&
      [ -d "/etc/rc.d/init.d" ] && {
        chown -Rv root:root /etc/rc.d
        chmod -Rv 0755 /etc/rc.d
      } &&
      ln -sf "/etc/rc.d/init.d" "${etcinitd_dir}"
    } &&
    [ -d "${etcinitd_dir}" ] && {
      for svinidsh in $( ls -1 \
        "${work_dir}"/postgresql*.sysvinit.sh \
        2>/dev/null || :;)
      do

        svshname="${svinidsh##*/}"
        svshname="${svshname%.sysvinit*}"

        [ -s "${svinidsh}" ] && {
          mv -fv "${svinidsh}" "${etcinitd_dir}/${svshname}" &&
          chown -v root:root "${etcinitd_dir}/${svshname}" &&
          chmod -v 0755 "${etcinitd_dir}/${svshname}"
        } ||
        etcinitd_ret=$?

      done &&
      [ ${etcinitd_ret:-1} -eq 0 ]
    } &&
    if [ -d "${etccrond_dir}" ]
    then
      for scrontab in $( ls -1 
        "${work_dir}"/postgresql*.crontab \
        2>/dev/null || :;)
      do

        scroname="${scrontab##*/}"

        [ -s "${scrontab}" ] && {
          mv -fv "${scrontab}" "${etccrond_dir}/${scroname}" &&
          chown -v root:root "${etccrond_dir}/${scroname}" &&
          chmod -v 0644 "${etccrond_dir}/${scroname}"
        } ||
        etcinitd_ret=$?

      done &&
      [ ${etcinitd_ret:-1} -eq 0 ]
    else :
    fi

  fi

} &&
: "${THIS}: Install postgresql.* scripts" && {

  pg_tools_dir="${pgsqldir}/bin"
  pg_share_dir="${pgsqldir}/share"
  pg_mkdirs_st=0

  for _dir in "${pgsqldir}" "${pg_tools_dir}" "${pg_share_dir}"
  do
    [ -d "${_dir}" ] || {
      mkdir -pv "${_dir}"
    } &&
    [ -d "${_dir}" ] && {
      chown -v root:root "${_dir}" &&
      chmod -v 0755 "${_dir}"
    } ||
    pg_mkdirs_st=$?
  done &&
  [ ${pg_mkdirs_st:-1} -eq 0 ] &&
  [ -d "${pgsqldir}/bin" ] && {
    for _scr in $( ls -1 \
      "${work_dir}"/postgresql.*.sh \
      2>/dev/null || :; )
    do
      _dst="${pg_tools_dir}/${_scr##*postgresql.}"
      mv -fv "${_scr}" "${_dst}" && {
        chown -v root:root "${_dst}" &&
        chmod -v 0775 "${_dst}"
      } ||
      pg_mkdirs_st=$?
    done &&
    [ ${pg_mkdirs_st:-1} -eq 0 ]
  }

} &&
: "${THIS}: Install onbuild scripts" && {

  onbuilddir="${pgsqldir}/.onbuild"
  onbuild_sh="${onbuilddir}/onbuild.sh"

  onbuildsrc="pg_${onbuild_sh##*/}"

  [ -s "${work_dir}/${onbuildsrc}" ] && {

    [ -d "${onbuilddir}" ] || {
      mkdir -pv "${onbuilddir}"
    } &&
    [ -d "${onbuilddir}" ] && {
      chown -v root:root "${onbuilddir}" &&
      chmod -v 0755 "${onbuilddir}"
    } &&
    [ -d "${onbuilddir}" ] && {
      mv -fv "${work_dir}/${onbuildsrc}" "${onbuild_sh}" &&
      chown -v root:root "${onbuild_sh}" &&
      chmod -v 0755 "${onbuild_sh}"
    }

  } &&
  [ ! -d "${work_dir}/onbuild" ] || {
    mv -fv "${work_dir}/onbuild"/* "${onbuilddir}/" &&
    chown -v root:root "${onbuilddir}/" &&
    chmod -v 0644 "${onbuilddir}"/* &&
    chmod -v 0755 "${onbuilddir}"/*.sh
  }

} &&
: "${THIS}: Done."

exit $?
