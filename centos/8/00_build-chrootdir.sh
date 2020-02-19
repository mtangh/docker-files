#!/bin/bash -ux
# CentOS built rootfs image
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

[ -n "${CENTOS_VER:-}" ] || exit 1
[ -n "${CENTOSROOT:-}" ] || exit 1

cat <<_EOD_
#*
#* CENTOS_VER${CENTOS_VER:-}
#* CENTOSROOT${CENTOSROOT:-}
#*
_EOD_

dnf_config_update() {
  local dnf_config="${1:-}"; shift
  [ -s "${dnf_config}" ] || return 2

  cat "${dnf_config}" |
  if egrep '^errorlevel=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(errorlevel)=*$/\1=8/g'
  else sed -re '/^gpgcheck=.*/a errorlevel=8'
  fi |
  if egrep '^debuglevel=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(debuglevel)=.*$/\1=8/g'
  else sed -re '/^errorlevel=.*/a debuglevel=8'
  fi |
  if egrep '^tsflags=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(tsflags)=.*$/\1=nodocs/g'
  else sed -re '/^best=.*/a tsflags=nodocs'
  fi |
  if egrep '^fastestmirror=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(fastestmirror)=.*$/\1=True/g'
  else sed -re '/^tsflags=.*$/a fastestmirror=True'
  fi |
  cat 1>"${dnf_config}.tmp" &&
  mv -f "${dnf_config}"{.tmp,} && {
    echo
    echo "[${dnf_config}]"
    cat "${dnf_config}"
    echo
  } || :

  return $?
}

: "Change the config of DNF" && {

  dnf_config_update \
    "/etc/dnf/dnf.conf" \
    || exit 1

} &&
: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial"

  mkdir -p "${CENTOSROOT}" && {

    dnf -v -y \
      reinstall --downloadonly --downloaddir . \
      centos-release centos-repos centos-gpg-keys &&
    rpm -v \
      --root ${CENTOSROOT} \
      --initdb &&
    rpm -v \
      --root ${CENTOSROOT} \
      --nodeps -ivh centos-*.rpm &&
    rpm -v \
      --root ${CENTOSROOT} \
      --import "${CENTOSROOT}${rpm_gpgkey}" &&
    dnf -v -y \
      --installroot=${CENTOSROOT} \
      --setopt=tsflags=nodocs \
      --setopt=fastestmirror=True \
      install dnf

  } || exit 1

  rm -f centos-*.rpm || :

} &&
: "Change the config of DNF under CENTOSROOT." && {

  dnf_config_update \
    "${CENTOSROOT}/etc/dnf/dnf.conf" \
    || exit 1

  # dnf vars
  echo "container" 1>"${CENTOSROOT}/etc/dnf/vars/infra"

} &&
: "Chroot Setup." && {

  cp -pf {,"${CENTOSROOT}"}/etc/resolv.conf &&
  chroot "${CENTOSROOT}" /bin/bash -ux <<'_EOD_'
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
    hostname \
    iputils \
    passwd \
    procps-ng \
    rootfiles \
    tar \
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
  dnf -v -y install \
    epel-release \
    || exit 1

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
    || exit 1

  # Remove packages as much as possible.
  dnf -v -y remove \
    coreutils-common \
    cracklib-dicts \
    diffutils \
    gettext \
    gettext-libs \
    glibc-all-langpacks \
    gnupg2-smime \
    hardlink \
    kbd \
    kpartx \
    libcroco \
    libevent \
    libgomp \
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
    rpm-plugin-systemd-inhibit \
    shared-mime-info \
    trousers \
    trousers-lib \
    which \
    || exit 1

  # Update and Cleanup.
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }

} &&
: "Fix /run/lock breakage since it's not tmpfs in docker" && {

  umount /run || :
  systemd-tmpfiles --create --boot || :

} &&
: "Initialize the root user password." && {

  # Randomize root password and lock
  dd if=/dev/urandom count=50 |md5sum |
  passwd --stdin root &&
  passwd -l root &&
  passwd -S root

} &&
: "Default Language." && {

  if [ -s "${langfile:=/etc/locale.conf}" ] &&
     egrep '^LANG=' "${langfile}" 1>/dev/null 2>&1
  then sed -ri 's/^LANG=.*$/LANG=en_US.UTF-8/g' "${langfile}"
  else echo 'LANG=en_US.UTF-8' 1>>"${langfile}"
  fi || :

} &&
: "Remove some things we don't need." && {

  rm -rf \
    /boot/* \
    /etc/firewalld \
    /etc/sysconfig/network-scripts/ifcfg-* \
    /usr/lib/locale/locale-archive \
    /root/* || :

  rm -rf \
    /etc/udev/hwdb.bin \
    /usr/lib/udev/hwdb.d/* || :

  # Cleanup all log files.
  for lf in /var/log/*
  do
    [ -s "${lf}" ] &&
    cat /dev/null 1>"${lf}" || :
  done

  # Cleanup /tmp/*.
  rm -rf {,/var}/tmp/* || :

  # Make sure login works.
  rm -f /var/run/nologin || :

} &&
: "Generate installtime file record." && {

  date +'%Y%m%dT%H%M%S%:z' 1>/etc/BUILDTIME || :

} &&
: "Remove 'resolv.conf'." && {

  rm -f /etc/resolv.conf || :

} &&
[ $? -eq 0 ]
_EOD_

} &&
: "Cleanup." && {
  work_dir=$(pwd); cd /
  for lf in /var/log/*
  do
    [ -s "${lf}" ] && cat /dev/null 1>"${lf}"
  done
  rm -f {,/var}/tmp/*
  yum -v -y clean all
  rm -rf /var/cache/dnf/*
} 2>/dev/null || : &&
: "Done."

exit $?
