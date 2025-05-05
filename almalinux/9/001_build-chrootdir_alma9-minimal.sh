#!/bin/bash
# 001_build-chrootdir_alma9-minimal.sh
THIS="${BASH_SOURCE}"
NAME="${THIS##*/}"
BASE="${NAME%.*}"
CDIR=$([ -n "${THIS%/*}" ] && cd "${THIS%/*}" &>/dev/null; pwd)

[ -n "${ALMALINUX_VER:-}" ] || exit 1
[ -n "${ALMALINUXROOT:-}" ] || exit 1

: "Chroot Setup." && {

cp -pf {,"${ALMALINUXROOT}"}/etc/resolv.conf &&
chroot "${ALMALINUXROOT}" /bin/bash -ux <<'_EOF_'
# Chroot setup.

: "Package setup." && {

  # Update
  dnf -v -y update || exit 1

  # Install packages.
  dnf -v -y install \
    bash \
    hostname \
    vim-minimal \
    || exit 1

  dnf -v -y remove \
    $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) \
    || exit 1

  # Update and Cleanup.
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }

} &&
: "Set Default runlevel." && {

  if [ -x "$(type -P systemctl)" ]
  then
     systemctl set-default multi-user.target
  else
    [ -e "/usr/lib/systemd/system/multi-user.target" ] &&
    ln -sfv /usr/lib/systemd/system/multi-user.target default.target || :
  fi

} &&
: "Remove some things we don't need." && {

  rm -rfv \
    /boot/* \
    /etc/firewalld \
    /etc/sysconfig/network-scripts/ifcfg-* \
    /run/* \
    /usr/lib/locale/locale-archive \
    /usr/share/mime/* \
    || :

  rm -rfv \
    /root/* \
    /root/.bash_history \
    || :

  rm -rfv \
    /etc/udev/hwdb.bin \
    /usr/lib/udev/hwdb.d/* \
    /var/log/hawkey.log \
    || :

  # Cleanup locales
  for lc in $(ls -1d /usr/share/locale/* |egrep -v '/(C|locale\.alias$)');
  do
    echo "${lc}" && rm -rf "${lc}"
  done

  # Cleanup all log files.
  [ -d "/var/log/" ] &&
  for lf in /var/log/*
  do
    [ -f "${lf}" -a -s "${lf}" ] && : 1>"${lf}"
    [ -d "${lf}" ] && rm -f "${lf}"/*
  done

  # Cleanup /var/lib/{dnf,rpm}/*
  rm -rf /var/cache/dnf/* \
         /var/cache/dnf/.gpgkeyschecked.yum \
         /var/lib/dnf/repos \
         /var/lib/dnf/modulefailsafe/* \
         /var/lib/dnf/history.* \
         /var/lib/rpm/__db.* || :

  # Cleanup /tmp/*.
  rm -rf {,/var}/tmp/* /tmp/.[A-Za-z]* || :

  # Make sure login works.
  rm -f /var/run/nologin || :

} &&
: "Initialize automatically generated files." && {

  # no machine-id by default.
  [ -s "/etc/machine-id" ]  && : > /etc/machine-id || :

  # Initializing 'resolv.conf' and 'hostname'
  [ -s "/etc/resolv.conf" ] && : > /etc/resolv.conf || :
  [ -s "/etc/hostname" ]    && : > /etc/hostname || :

} &&
: "Generate installtime file record." && {

  date +'%Y%m%dT%H%M%S%:z' 1>/etc/BUILDTIME || :

} &&
[ $? -eq 0 ]
_EOF_

} &&
: "Cleanup." && {
  work_dir=$(pwd)
  cd / && {
    for lf in /var/log/*
    do
      [ -f "${lf}" -a -s "${lf}" ] && : 1>"${lf}"
      [ -d "${lf}" ] && rm -f "${lf}"/*
    done
    rm -f {,/var}/tmp/* /tmp/.[A-Za-z]*
    rm -rf /var/lib/dnf/repos
    rm -f  /var/lib/dnf/modulefailsafe/* \
           /var/lib/dnf/history.*
    rm -f  /var/lib/rpm/__db.*
  } 2>/dev/null || :
} &&
: "Done."

exit $?
