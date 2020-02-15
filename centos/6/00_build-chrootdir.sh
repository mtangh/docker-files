#!/bin/bash -ux
# CentOS built rootfs image
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

[ -n "${CENTOS_VER:-}" ] || exit 1
[ -n "${CENTOSROOT:-}" ] || exit 1

rpm="rpm -v"
yum="yum -v -y"

rpm_chroot="${rpm} --root ${CENTOSROOT}"

yum_chroot="${yum}"
yum_chroot="${yum_chroot} --installroot=${CENTOSROOT}"
yum_chroot="${yum_chroot} --setopt=override_install_langs=en_US.UTF-8"
yum_chroot="${yum_chroot} --setopt=tsflags=nodocs"

: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER}"

  mkdir -p "${CENTOSROOT}" &&
  ${yum} reinstall --downloadonly --downloaddir . centos-release &&
  ${rpm_chroot} --initdb &&
  ${rpm_chroot} --nodeps -ivh centos-release*.rpm &&
  rm -f centos-release*.rpm &&
  ${rpm_chroot} --import "${CENTOSROOT}${rpm_gpgkey}" &&
  ${yum_chroot} install yum

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
  ${yum_chroot} update &&
  ${yum_chroot} install \
    bash \
    bind-utils \
    findutils \
    iputils \
    iproute \
    passwd \
    rootfiles \
    shadow-utils \
    tar \
    util-linux-ng \
    vim-minimal \
    yum-plugin-fastestmirror \
    yum-plugin-ovl \
    yum-utils \
    || exit 1

  # Install EPEL
  ${yum_chroot} install \
    epel-release \
    || exit 1

  # remove stuff we don't need that anaconda insists on
  # kernel needs to be removed by rpm, because of grubby
  ${rpm_chroot} -e kernel || :

  # Remove
  ${yum_chroot} remove \
    bind-license \
    centos-logos \
    dbus-glib \
    dbus-python \
    device-mapper* \
    dhclient \
    dhcp-libs \
    dracut \
    dracutinstall \
    e2fsprogs-libs \
    ebtables \
    firewalld \
    freetype \
    gettext* \
    gobject-introspection \
    grub2 \
    grubby \
    hwdata \
    kbd-misc \
    kernel-firmware \
    kmod \
    kmod-libs \
    kpartx \
    libselinux-python \
    libss \
    os-prober \
    pygobject3-base \
    python-decorator \
    python-slip \
    python-slip-dbus \
    sysvinit-tools \
    upstart \
    which \
    || exit 1

  # yum cleanup
  ${yum_chroot} update &&
  ${yum_chroot} clean all
  rm -rf ${CENTOSROOT}/var/cache/yum/*

  # Disable services
  : && {
    chroot "${CENTOSROOT}" /bin/bash -ux <<_EOF_
for serv in $(/sbin/chkconfig|cut -f1)
do
   M/sbin/chkconfig "$serv" off
done
# udev-post
[ -e "/etc/rc1.d/S26udev-post" ] && {
  mv /etc/rc1.d/S26udev-post /etc/rc1.d/K26udev-post
} || :
_EOF_
  } || :

  # Remove some things we don't need
  rm -rf \
    ${CENTOSROOT}/boot/* \
    ${CENTOSROOT}/etc/firewalld \
    ${CENTOSROOT}/etc/sysconfig/network-scripts/ifcfg-* \
    ${CENTOSROOT}/usr/lib/locale/locale-archive
    ${CENTOSROOT}/tmp/ks-script* \
    ${CENTOSROOT}/root/*

  # Make sure login works
  rm -f ${CENTOSROOT}/var/run/nologin

  # Cleanup all log files
  for log_file in ${CENTOSROOT}/var/log/*
  do
    [ -s "${log_file}" ] &&
    cat /dev/null 1>"${log_file}" || :
  done

  # Cleanup tmp.
  rm -f ${CENTOSROOT}{,/var}/tmp/*

  # Generate installtime file record
  /bin/date +'%Y%m%dT%H%M%S%:z' 1>${CENTOSROOT}/etc/BUILDTIME || :

} &&
: "Configure YUM and Plugins." && {

  # Enable yum plugins
  yum_conf="${CENTOSROOT}/etc/yum.conf"
  cat "${yum_conf}" |
  sed -re 's/^(#*)plugins=[01]$/plugins=1/g' |
  sed -re "/^distroverpkg=centos-.*/a override_install_langs=en_US.UTF-8" |
  sed -re "/^override_install_langs=.*/a tsflags=nodocs" |
  cat 1>"${yum_conf}.tmp" &&
  mv -f "${yum_conf}"{.tmp,} &&{
    echo
    echo "[${yum_conf}]"
    cat ${yum_conf}
    echo
  } || :

  # Modify yum-fastestmirror
  yum_plgcnf="${CENTOSROOT}/etc/yum/pluginconf.d"
  yum_fm_cnf="${yum_plgcnf}/fastestmirror.conf"
  yum_fmserv="${YUM_FAST_MIRROR:-}"
  yum_dominc="${YUM_FM_DOM_INCL:-.org}"
  yum_domexc="${YUM_FM_DOM_EXCL:-}"
  [ -e "${yum_fm_cnf}" ] && {
    cat "${yum_fm_cnf}" |
    sed -r \
      -e 's/^(#*)enabled=[01]$/enabled=1/g' \
      -e 's/^(#*)verbose=[01]$/verbose=1/g' \
      -e 's/^(#*)include_only=.*$/include_only='"${yum_dominc}"'/g' |
    if [ -n "${yum_domexc}" ]
    then sed -r -e 's/^(#*)exclude=.*$/exclude='"${yum_domexc}"'/g'
    else cat
    fi |
    if [ -n "${yum_fmserv}" ]
    then sed -r -e '/^include_only=.*$/a prefer='"${yum_fmserv}"
    else cat
    fi |
    cat 1>"${yum_fm_cnf}.tmp" &&
    mv -f "${yum_fm_cnf}"{.tmp,} && {
      echo
      echo "[${yum_fm_cnf}]"
      cat "${yum_fm_cnf}"
      echo
    }
    [ $? -eq 0 ] || exit 1
  } || :

  # yum vars
  echo "container" 1>/etc/yum/vars/infra

} &&
: "Set the root user." && {

  : && {
    chroot "${CENTOSROOT}" /bin/bash -ux <<_EOF_
# Randomize root password and lock
dd if=/dev/urandom count=50 |md5sum |
passwd --stdin root &&
passwd -l root &&
passwd -S root
_EOF_
  } || exit 1

} &&
: "Default Language." && {

  echo 'LANG=en_US.UTF-8' 1>${CENTOSROOT}/etc/locale.conf

} &&
: "Cleanup." && {
  cd /;
  for lf in /var/log/*;
  do [ -f "${lf}" ] && cat /dev/null 1>"${lf}"; done;
  yum -v -y clean all; rm -rf /var/cache/yum/*;
} 2>/dev/null || : &&
: "Done."

exit $?
