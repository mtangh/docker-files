#!/bin/bash
# 002_build-chrootdir_alma9-init.sh
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
    findutils \
    iputils \
    procps-ng \
    rootfiles \
    tar \
    || exit 1

  # Unprotected
  if [ -s "${dnf_protect_conf:=/etc/dnf/protected.d/systemd.conf}" ]
  then
    cat "${dnf_protect_conf}" |
    egrep -v '^systemd-udev$' >"${dnf_protect_conf}.tmp" &&
    mv -f "${dnf_protect_conf}"{.tmp,}
  fi

  # Remove packages as much as possible.
  dnf -v -y remove \
    systemd-udev \
    || :

  dnf -v -y remove \
    $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) \
    || exit 1

  # Update and Cleanup.
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }

  # Fix /run/lock breakage since it's not tmpfs in docker
  mount 2>/dev/null |
  egrep '[[:space:]]/run[[:space:]]' 2>&1 1>/dev/null && {
    umount /run || :
    systemd-tmpfiles --create --boot || :
  }

  # mask mounts and login bits
  systemctl mask \
    console-getty.service \
    dev-hugepages.mount \
    getty.target \
    sys-fs-fuse-connections.mount \
    systemd-logind.service \
    systemd-machine-id-commit.service \
    systemd-random-seed.service \
    systemd-remount-fs.service \
    systemd-udev-trigger.service \
    systemd-udevd.service \
    || :

  # Install systemd-container
  : || {
    dnf -v -y update &&
    dnf -v -y install systemd-container && {
      dnf -v -y remove \
        $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) || :
    } &&
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  } || :

  # Remove systemd files (/etc)
  ( cd "${etc_sysd_dir:=/etc/systemd/system}/" && {
    :
  }; ) || :

  # Remove systemd files (/usr/lib)
  ( cd "${lib_sysd_dir:=/usr/lib/systemd/system}/" && {
    rm -frv \
      anaconda.target.wants/* \
      basic.target.wants/* \
      initrd.target.wants/ \
      local-fs.target.wants/* \
      system-update.target.wants/ \
      || :
  }; )|| :

  # AL9 specific hacks.
  mkdir -p /run/cryptsetup &&
  chmod 700 /run/cryptsetup || :
  mkdir -p \
    /run/{lock/subsys,log,user} \
    /run/systemd/{ask-password,machines,seats,sessions,shutdown,users} || :

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

  # Cleanup /var/cache/dnf, /var/lib/{dnf,rpm}/*
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
    rm -f  {,/var}/tmp/* /tmp/.[A-Za-z]*
    rm -rf /var/lib/dnf/repos
    rm -f  /var/lib/dnf/modulefailsafe/* \
           /var/lib/dnf/history.*
    rm -f  /var/lib/rpm/__db.*
  } 2>/dev/null || :
} &&
: "Done."

exit $?
