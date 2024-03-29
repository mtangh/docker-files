#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail
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

yum_check_obsolate() {
  local instroot="${1:-}"; shift
  local alt_host="linuxsoft.cern.ch/centos-vault"
  local checkpkg="centos-release"
  local yumcheck="yum info ${checkpkg}"
  local yumrepod="/etc/yum.repos.d"
  [ -d "${instroot:-X}" ] && {
    yumcheck="yum --installroot=${instroot} info ${checkpkg}"
    yumrepod="${instroot}${yumrepod}"
  } || :
  ${yumcheck} 1>/dev/null || {
    ( cd "${yumrepod}" && {
      sed -ri 's|^(mirrorlist=)|#\1|g' ./*.repo &&
      sed -ri 's|^#(baseurl=http://)[^/]+/|\1'"${alt_host}"'/|g' ./*.repo &&
      cat ./*.repo &&
      : "done"
    }; ) &&
    ${yumcheck} 1>/dev/null
  } ||
  return $?
  return 0
}

yum_config_update() {
  local yum_config="${1:-}"; shift
  local yum_fm_cnf="${1:-}"; shift
  [ -s "${yum_config}" ] || return 2
  [ -s "${yum_fm_cnf}" ] || return 2

  cat "${yum_config}" |
  sed -re 's/^[#[:space:]]*(plugins)=.*$/\1=1/g' |
  if egrep '^[#[:space:]]*override_.+_langs=' \
    "${yum_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(override_.+_langs)=.*$/\1=en_US.UTF-8/g'
  else sed -re '/^[#[:space:]]*distroverpkg=.*/a override_install_langs=en_US.UTF-8'
  fi |
  if egrep '^[#[:space:]]*tsflags=' \
    "${yum_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(tsflags)=.*$/\1=nodocs/g'
  else sed -re '/^override_.+_langs=.*/a tsflags=nodocs'
  fi |
  cat 1>"${yum_config}.tmp" && {
    echo
    echo "[${yum_config}]"
    diff "${yum_config}"{,.tmp} || :
    echo
  } &&
  mv -f "${yum_config}"{.tmp,} ||
  return $?

  # Modify yum-plugin-fastestmirror
  yum_fmserv="${YUM_FAST_MIRROR:-}"
  yum_dominc="${YUM_FM_DOM_INCL:-.org}"
  yum_domexc="${YUM_FM_DOM_EXCL:-}"
  if [ -e "${yum_fm_cnf}" ]
  then
    cat "${yum_fm_cnf}" |
    sed -r \
      -e 's/^[#[:space:]]*(enabled)=.*$/\1=1/g' \
      -e 's/^[#[:space:]]*(verbose)=.*$/\1=1/g' \
      -e 's/^[#[:space:]]*(inc.*_only)=.*$/\1='"${yum_dominc}"'/g' |
    if [ -n "${yum_domexc}" ]
    then
      if egrep '^[#[:space:]]*exclude=.*$' \
        "${yum_fm_cnf}"  1>/dev/null 2>&1
      then sed -re 's/^[#[:space:]]*(exclude)=.*$/\1='"${yum_domexc}"'/g'
      else sed -re '/^[#[:space:]]*verbose=.*$/a exclude='"${yum_domexc}"
      fi
    else cat
    fi |
    if [ -n "${yum_fmserv}" ]
    then
      if egrep '^[#[:space:]]*prefer=.*$' \
        "${yum_fm_cnf}" 1>/dev/null 2>&1
      then sed -re 's/^[#[:space:]]*(prefer)=.*$/\1='"${yum_fmserv}"'/g'
      else sed -re '/^[#[:space:]]*inc.+_only=.*$/a prefer='"${yum_fmserv}"
      fi
    else cat
    fi |
    cat 1>"${yum_fm_cnf}.tmp" && {
      echo
      echo "[${yum_fm_cnf}]"
      diff "${yum_fm_cnf}"{,.tmp}
      echo
    } &&
    mv -f "${yum_fm_cnf}"{.tmp,}
  else :
  fi ||
  return $?

  return 0
}

: "Check the support status of this CentOS version" && {

  yum_check_obsolate

} &&
: "Change the config of YUM and plugins" && {

  yum -v -y install \
    yum-plugin-fastestmirror || :

  yum_config_update \
    "/etc/yum.conf" \
    "/etc/yum/pluginconf.d/fastestmirror.conf" \
    || exit 1

} &&
: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER}"

  mkdir -p "${CENTOSROOT}" && {

    yum -v -y \
      clean all &&
    yum -v -y \
      update &&
    yum -v -y \
      reinstall --downloadonly --downloaddir . \
      centos-release &&
    rpm -v \
      --root ${CENTOSROOT} \
      --initdb &&
    rpm -v \
      --root ${CENTOSROOT} \
      --nodeps -ivh centos-*.rpm &&
    rpm -v \
      --root ${CENTOSROOT} \
      --import "${CENTOSROOT}${rpm_gpgkey}" &&
    yum_check_obsolate "${CENTOSROOT}" &&
    yum -v -y \
      --installroot=${CENTOSROOT} \
      --setopt=override_install_langs=en_US.UTF-8 \
      --setopt=tsflags=nodocs \
      install yum

  } || exit 1

  rm -f centos-*.rpm || :

} &&
: "Change the config of YUM and plugins under CENTOSROOT." && {

  yum_config_update \
    "${CENTOSROOT}/etc/yum.conf" \
    "${CENTOSROOT}/etc/yum/pluginconf.d/fastestmirror.conf" \
    || exit 1

  # yum vars
  echo "container" 1>${CENTOSROOT}/etc/yum/vars/infra

} &&
: "Chroot setup." && {

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
  yum -v -y update || exit 1

  # Install packages.
  yum -v -y install \
    bash \
    bind-utils \
    hostname \
    iputils \
    iproute \
    passwd \
    rootfiles \
    sudo \
    tar \
    vim-minimal \
    yum-plugin-ovl \
    yum-utils \
    || exit 1

  # Install EPEL.
  yum -v -y install \
    epel-release \
    || exit 1

  # remove stuff we don't need that anaconda insists on
  # kernel needs to be removed by rpm, because of grubby.
  rpm -v -e kernel || :

  # Remove logos
  rpm -v -e --nodeps \
    redhat-logos \
    || :

  # Remove packages as much as possible.
  yum -v -y remove \
    bind-license \
    dbus-glib \
    dbus-python \
    device-mapper* \
    dhclient \
    dhcp-common \
    dhcp-libs \
    dracut \
    dracutinstall \
    e2fsprogs-libs \
    ebtables \
    ethtool \
    file \
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

  # Package cleanup
  yum -v -y remove \
    $(echo $(package-cleanup --leaves)) \
    || exit 1

  # Update and Cleanup.
  yum -v -y update && {
    yum -v -y clean all &&
    rm -rf /var/cache/yum/* || :
  }

} &&
: "Disable services." && {

  for sn in $(/sbin/chkconfig|cut -f1)
  do
     [ -n "${sn}" ] && /sbin/chkconfig "${sn}" off || :
  done

  # udev-post
  [ -e "/etc/rc1.d/S26udev-post" ] && {
    mv /etc/rc1.d/S26udev-post /etc/rc1.d/K26udev-post
  } || :

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

  if [ -s "${langfile:=/etc/sysconfig/i18n}" ] &&
     egrep '^LANG=' "${langfile}" 1>/dev/null 2>&1
  then sed -ri 's/^LANG=.*$/LANG=en_US.UTF-8/g' "${langfile}"
  else echo 'LANG=en_US.UTF-8' 1>>"${langfile}"
  fi || :
  if [ -s "${langfile}" ] &&
     egrep '^LC_ALL=' "${langfile}" 1>/dev/null 2>&1
  then sed -ri 's/^LC_ALL=.*$/LC_ALL=C/g' "${langfile}"
  else echo 'LC_ALL=C' 1>>"${langfile}"
  fi || :

} &&
: "Remove some things we don't need." && {

  rm -rfv \
    /boot/* \
    /etc/firewalld \
    /etc/sysconfig/network-scripts/ifcfg-* \
    /usr/lib/locale/locale-archive \
    /root/* || :

  for lc in $(ls -1d /usr/share/locale/* |egrep -v '/(en|locale\.alias$)');
  do
    echo "${lc}" && rm -rf "${lc}"
  done

  # Cleanup all log files.
  [ -d "/var/log/" ] &&
  for lf in /var/log/*
  do
    [ -s "${lf}" ] && : 1>"${lf}" || :
  done

  # Cleanup /var/lib/rpm/__db.*
  rm -f /var/lib/rpm/__db.* || :

  # Cleanup /tmp/*.
  rm -rf {,/var}/tmp/* || :

  # Make sure login works.
  rm -f /var/run/nologin || :

} &&
: "Generate installtime file record." && {

  date +'%Y%m%dT%H%M%S%:z' 1>/etc/BUILDTIME || :

} &&
: "Remove '/etc/resolv.conf'." && {

  rm -f /etc/resolv.conf || :

} &&
[ $? -eq 0 ]
_EOD_

} &&
: "Cleanup." && {
  work_dir=$(pwd)
  cd / && {
    for lf in /var/log/*
    do
      [ -f "${lf}" ] && : 1>"${lf}"
    done
    rm -f {,/var}/tmp/*
    yum -v -y clean all
    rm -rf /var/cache/yum/*
    rm -f /var/lib/rpm/__db.*
  } 2>/dev/null || :
} &&
: "Done."

exit $?
