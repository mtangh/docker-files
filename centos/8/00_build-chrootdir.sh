#!/bin/bash -ux
# CentOS built rootfs image
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

[ -n "${CENTOS_VER:-}" ] || exit 1
[ -n "${CENTOSROOT:-}" ] || exit 1

cat <<_EOF_
#*
#* CENTOS_VER${CENTOS_VER:-}
#* CENTOSROOT${CENTOSROOT:-}
#*
_EOF_

rpm="rpm -v"
dnf="dnf -v -y"

rpm_chroot="${rpm} --root ${CENTOSROOT}"

dnf_chroot="${dnf}"
dnf_chroot="${dnf_chroot} --installroot=${CENTOSROOT}"
dnf_chroot="${dnf_chroot} --setopt=tsflags=nodocs"
#dnf_chroot="${dnf_chroot} --setopt=override_install_langs=en_US.UTF-8"

: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial"

  mkdir -p "${CENTOSROOT}" &&
  ${dnf} reinstall --downloadonly --downloaddir . \
    centos-release centos-repos centos-gpg-keys &&
  ${rpm_chroot} --initdb &&
  ${rpm_chroot} --nodeps -ivh centos-*.rpm &&
  rm -f centos-*.rpm &&
  ${rpm_chroot} --import "${CENTOSROOT}${rpm_gpgkey}" &&
  ${dnf_chroot} install dnf

} &&
: "Package setup" && {

  # /dev files
  [ -e "${CENTOSROOT}/dev/null" ]    || mknod -m 666 ${CENTOSROOT}/dev/null c 1 3
  [ -e "${CENTOSROOT}/dev/zero" ]    || mknod -m 666 ${CENTOSROOT}/dev/zero c 1 5
  [ -e "${CENTOSROOT}/dev/random" ]  || mknod -m 666 ${CENTOSROOT}/dev/random c 1 8
  [ -e "${CENTOSROOT}/dev/urandom" ] || mknod -m 666 ${CENTOSROOT}/dev/urandom c 1 9

  # Rebuild RPM DB
  ${rpm_chroot} --rebuilddb

  # Package setup
  ${dnf_chroot} update &&
  ${dnf_chroot} install \
    bash \
    hostname \
    iputils \
    passwd \
    procps-ng \
    rootfiles \
    tar \
    vim-minimal \
    || exit 1
  ${dnf_chroot} install --best --allowerasing \
    coreutils-single \
    glibc-minimal-langpack \
    libcurl-minimal \
    || exit 1

  # Install EPEL
  ${dnf_chroot} install \
    epel-release \
    || exit 1

  # remove stuff we don't need that anaconda insists on
  # kernel needs to be removed by rpm, because of grubby
  ${rpm_chroot} -e \
    kernel \
    || :

  # remove grub* and grubby
  ${rpm_chroot} -e \
    grub2-common \
    grub2-tools \
    grub2-tools-minimal \
    grubby \
    || exit 1

  # Remove
  ${dnf_chroot} remove \
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

  # Fix /run/lock breakage since it's not tmpfs in docker
  : "Chroot" && {
    cp -pf {,"${CENTOSROOT}"}/etc/resolv.conf &&
    chroot "${CENTOSROOT}" /bin/bash -ux <<'_EOD_'
: "DNF update and cleanup." && {
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }
} &&
: "Fix /run/lock breakage since it's not tmpfs in docker" && {
  umount /run || :
  systemd-tmpfiles --create --boot || :
} &&
: "Set the root user." && {
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
: "Remove some things we don't need" && {
  rm -rf \
    /boot/* \
    /etc/firewalld \
    /etc/sysconfig/network-scripts/ifcfg-* \
    /usr/lib/locale/locale-archive \
    /root/* || :
  rm -rf \
    /etc/udev/hwdb.bin \
    /usr/lib/udev/hwdb.d/* || :
} &&
: "Make sure login works" && {
  rm -f /var/run/nologin || :
} &&
: "Cleanup all log files" && {
  for lf in /var/log/*
  do
    [ -s "${lf}" ] &&
    cat /dev/null 1>"${lf}" || :
  done
} &&
: "Cleanup tmp." && {
  rm -rf {,/var}/tmp/* || :
} &&
: "Generate installtime file record." && {
  date +'%Y%m%dT%H%M%S%:z' 1>/etc/BUILDTIME || :
} &&
: "Remove '/etc/resolv.conf'." && {
  rm -f /etc/resolv.conf || :
} &&
[ $? -eq 0 ]
_EOD_
  } || exit 1

} &&
: "Configure DNF and Plugins." && {

  # Enable dnf plugins
  dnf_config="${CENTOSROOT}/etc/dnf/dnf.conf"
  cat "${dnf_config}" |
  sed -re '/^gpgcheck=*/a debuglevel=8' |
  sed -re '/^debuglevel=*/a errorlevel=8' |
  sed -re '/^best=.*/a tsflags=nodocs' |
  sed -re '/^tsflags=.*$/a fastestmirror=1' |
  cat 1>"${dnf_config}.tmp" &&
  mv -f "${dnf_config}"{.tmp,} &&{
    echo
    echo "[${dnf_config}]"
    cat ${dnf_config}
    echo
  } || :

  # dnf vars
  echo "container" 1>${CENTOSROOT}/etc/dnf/vars/infra

} &&
: "Cleanup." && {
  work_dir=$(pwd); cd /
  for lf in /var/log/*
  do
    [ -f "${lf}" ] &&
    cat /dev/null 1>"${lf}"
  done
  rm -f {,/var}/tmp/*
  yum -v -y clean all
  rm -rf /var/cache/dnf/*
} 2>/dev/null || : &&
: "Done."

exit $?
