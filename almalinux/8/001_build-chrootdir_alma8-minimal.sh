#!/bin/bash
# 001_build-chrootdir_alma8-minimal.sh

: "Make /dev files." && {

  [ -e "/dev/null" ]    || mknod -m 666 /dev/null c 1 3
  [ -e "/dev/zero" ]    || mknod -m 666 /dev/zero c 1 5
  [ -e "/dev/random" ]  || mknod -m 666 /dev/random c 1 8
  [ -e "/dev/urandom" ] || mknod -m 666 /dev/urandom c 1 9

} &&
: "Package setup." && {

  # Rebuild RPM DB.
  rpm -v --rebuilddb &&
  dnf -v -y update || exit 1

  # Install packages.
  dnf -v -y install \
    bash \
    vim-minimal \
    || exit 1

  # Switch to minimal package
  dnf -v -y install \
    --best --allowerasing \
    coreutils-single \
    glibc-minimal-langpack \
    libcurl-minimal \
    || exit 1

  # Install EPEL.
  if [ "${INSTALLEPEL:-}" = "YES" ]
  then
    dnf -v -y install \
      epel-release \
      || exit 1
  fi

  # remove stuff we don't need that anaconda insists on
  # kernel needs to be removed by rpm, because of grubby.
  rpm -v -e \
    kernel \
    || :

  # No boot loader needed.
  rpm -v -e \
    grub2-common \
    grub2-tools \
    grub2-tools-minimal \
    grubby \
    || :

  # Unprotected
  if [ -s "${dnf_protect_conf:=/etc/dnf/protected.d/systemd.conf}" ]
  then
    cat "${dnf_protect_conf}" |
    egrep -v '^systemd-udev$' >"${dnf_protect_conf}.tmp" &&
    mv -f "${dnf_protect_conf}"{.tmp,}
  fi

  # Remove packages as much as possible.
  dnf -v -y remove --exclude=findutils \
    systemd-udev \
    || :

  dnf -v -y remove --exclude=findutils \
    binutils \
    brotli \
    coreutils-common \
    crypto-policies-scripts \
    diffutils \
    dnf-plugins-core \
    elfutils-debuginfod-client \
    gettext \
    gettext-libs \
    glibc-all-langpacks \
    glibc-gconv-extra \
    gnupg2-smime \
    hardlink \
    kbd \
    kmod \
    kpartx \
    libcroco \
    libevent \
    libgomp \
    libkcapi \
    libkcapi-hmaccalc \
    libpsl \
    libsecret \
    libssh \
    libssh-config \
    libxkbcommon \
    ncurses \
    openssl \
    openssl-pkcs11 \
    os-prober \
    pigz \
    platform-python-pip \
    procps-ng \
    rpm-plugin-systemd-inhibit \
    shared-mime-info \
    trousers \
    trousers-lib \
    which \
    || :

  dnf -v -y remove --exclude=findutils \
    $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) \
    || exit 1

  # Update and Cleanup.
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }

} &&
: "Initialize the root user password." && {

  # Randomize root password
  set +x && {
    rootpswd_tmp=$(dd status=none if=/dev/urandom count=50 |md5sum)
    rootpswd_tmp="${rootpswd_tmp%% *}"
  } &&
  if [ -x "$(type -P passwd)" ]
  then
    echo "Set a root password and lock."
    echo "${rootpswd_tmp}" |passwd --stdin root &&
    passwd -l root &&
    passwd -S root
  else
    echo "Set a root password"
    echo "root:${rootpswd_tmp}" |chpasswd
  fi &&
  set -x

} &&
: "Default Language." && {

  LANG="C.UTF-8"

  [ -s "${langfile:=/etc/locale.conf}" ] ||
  touch "${langfile}" || :

  if egrep '^LANG=' "${langfile}" 1>/dev/null 2>&1
  then sed -ri 's/^LANG=.*$/LANG='"${LANG}"'/g' "${langfile}"
  else echo "LANG=${LANG}" 1>>"${langfile}"
  fi || :

  echo '%_install_langs C.utf8' 1>"/etc/rpm/macros.image-language-conf"

} &&
: "Default virtual console configuration." && {

  [ -s "${vcnsfile:=/etc/vconsole.conf}" ] ||
  touch "${vcnsfile}" || :

  if egrep '^KEYMAP=' "${vcnsfile}" 1>/dev/null 2>&1
  then sed -ri 's/^KEYMAP=.*$/KEYMAP=us/g' "${vcnsfile}"
  else echo "KEYMAP=us" 1>>"${vcnsfile}"
  fi || :

  if egrep '^FONT=' "${vcnsfile}" 1>/dev/null 2>&1
  then sed -ri 's/^FONT=.*$/FONT=eurlatgr/g' "${vcnsfile}"
  else echo "FONT=eurlatgr" 1>>"${vcnsfile}"
  fi || :

} &&
: "Default timezone." && {

  ( cd /etc && {
    ln -sf ../usr/share/zoneinfo/UTC ./localtime;
    : "adjtime" && {
      echo "0.0 0 0.0"
      echo "0"
      echo "UTC"
    } 1>/etc/adjtime
  }; )

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
  rm -rf /var/lib/dnf/repos \
         /var/lib/dnf/modulefailsafe/* \
         /var/lib/dnf/history.* \
         /var/lib/rpm/__db.* || :

  # Cleanup /tmp/*.
  rm -rf {,/var}/tmp/* || :

  # Make sure login works.
  rm -f /var/run/nologin || :

} &&
: "Remove 'resolv.conf' and 'hostname'." && {

  rm -f /etc/resolv.conf || :
  rm -f /etc/hostname || :

} &&
: "Generate installtime file record." && {

  date +'%Y%m%dT%H%M%S%:z' 1>/etc/BUILDTIME || :

} &&
[ $? -eq 0 ]

exit $?
