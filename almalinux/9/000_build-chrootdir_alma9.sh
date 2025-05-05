#!/bin/bash
# AlmaLinux built "build-stage_base" image
THIS="${BASH_SOURCE}"
NAME="${THIS##*/}"
BASE="${NAME%.*}"
CDIR=$([ -n "${THIS%/*}" ] && cd "${THIS%/*}" &>/dev/null; pwd)

set -ux -o errtrace -o functrace -o pipefail

[ -n "${ALMALINUX_VER:-}" ] || exit 1
[ -n "${ALMALINUXROOT:-}" ] || exit 1

# DNF
dnf=""
[ -x "${dnf:-}" ] || dnf="$(type -P dnf)"
[ -x "${dnf:-}" ] || dnf="$(type -P microdnf)"
[ -x "${dnf:-}" ] || exit 1
case "${dnf:-}" in
*/microdnf)
  ;;
*)
  dnf="${dnf} -v"
  ;;
esac

cat <<_EOD_
#*
#* ALMALINUX_VER=${ALMALINUX_VER:-}
#* ALMALINUXROOT=${ALMALINUXROOT:-}
#*
#* INSTALLEPEL=${INSTALLEPEL:-}
#*
#* Using dnf: ${dnf}
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
  if egrep '^install_weak_deps=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(install_weak_deps)=.*$/\1=False/g'
  else sed -re '/^best=.*/a install_weak_deps=False'
  fi |
  if egrep '^tsflags=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(tsflags)=.*$/\1=nodocs/g'
  else sed -re '/^install_weak_deps=.*/a tsflags=nodocs'
  fi |
  if egrep '^fastestmirror=' "${dnf_config}" 1>/dev/null 2>&1
  then sed -re 's/^[#[:space:]]*(fastestmirror)=.*$/\1=True/g'
  else sed -re '/^tsflags=.*$/a fastestmirror=True'
  fi |
  cat 1>"${dnf_config}.tmp" && {
    echo
    echo "[${dnf_config}]"
    if [ -x "$(type -P diff)" ]
    then
      diff "${dnf_config}"{,.tmp}
    else
      cat "${dnf_config}.tmp"
    fi || :
    echo
  } &&
  mv -f "${dnf_config}"{.tmp,} ||
  return $?

  return 0
}

: "Change the config of DNF" && {

  case "${dnf}" in
  */microdnf)
    ${dnf} -y install --nodocs dnf-data
    ${dnf} -y clean all
    ;;
  *)
    ;;
  esac || :

  if [ -s "/etc/dnf/dnf.conf" ]
  then
    dnf_config_update \
      "/etc/dnf/dnf.conf" \
      || exit 1
  fi

} &&
: "Initialize Chroot Dir." && {

  ${dnf} -y update

  rpm_gpgkey=""
  if [ -f "/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-${ALMALINUX_VER}" ]
  then rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux-${ALMALINUX_VER}"
  elif [ -f "/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux" ]
  then rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-AlmaLinux"
  fi

  mkdir -p "${ALMALINUXROOT}" && {

    ${dnf} -y \
      clean all &&
    ${dnf} -y \
      --nodocs \
      update &&
    case "${dnf}" in
    */microdnf)
      ${dnf} -y \
        download \
        almalinux-gpg-keys \
        almalinux-release \
        almalinux-repos
      ;;
    *)
      ${dnf} -y \
        reinstall --downloadonly --downloaddir . \
        almalinux-gpg-keys \
        almalinux-release \
        almalinux-repos
      ;;
    esac &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --initdb &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --nodeps --excludedocs -ivh almalinux-*.rpm &&
    rpm -v \
      --root ${ALMALINUXROOT} \
      --import "${ALMALINUXROOT}${rpm_gpgkey}" &&
    case "${dnf}" in
    */microdnf)
      ${dnf} -y \
        --releasever=${ALMALINUX_VER} \
        --installroot=${ALMALINUXROOT} \
        --config=/etc/dnf/dnf.conf --nodocs --noplugins \
        --setopt=cachedir=${ALMALINUXROOT}/var/cache/dnf \
        --setopt=reposdir=/etc/yum.repos.d \
        --setopt=varsdir=${ALMALINUXROOT}/etc/dnf/vars/ \
        --setopt=install_weak_deps=0 \
        --setopt=tsflags=nodocs \
        install dnf dnf-data
      ;;
    *)
      ${dnf} -y \
        --releasever=${ALMALINUX_VER} \
        --installroot=${ALMALINUXROOT} \
        --nodocs \
        --setopt=install_weak_deps=0 \
        --setopt=tsflags=nodocs \
        install dnf dnf-data
      ;;
    esac

  } || exit 1

  rm -f almalinux-*.rpm || :

  ${dnf} -y clean all

} &&
: "Change the config of DNF under ALMALINUXROOT." && {

  dnf_config_update \
    "${ALMALINUXROOT}/etc/dnf/dnf.conf" \
    || exit 1

  # dnf vars
  echo "container" 1>"${ALMALINUXROOT}/etc/dnf/vars/infra"

} &&
: "Chroot Setup." && {

cp -pf {,"${ALMALINUXROOT}"}/etc/resolv.conf &&
chroot "${ALMALINUXROOT}" /bin/bash -ux <<'_EOF_'
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
    curl-minimal \
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
  dnf -v -y remove \
    systemd-udev \
    || :

#  dnf -v -y remove \
#    brotli \
#    crypto-policies-scripts \
#    diffutils \
#    gettext \
#    gettext-libs \
#    glibc-all-langpacks \
#    gnupg2-smime \
#    kbd \
#    kmod \
#    kpartx \
#    libcroco \
#    libkcapi \
#    libkcapi-hmaccalc \
#    libsecret \
#    libxkbcommon \
#    ncurses \
#    os-prober \
#    pigz \
#    platform-python-pip \
#    procps-ng \
#    shared-mime-info \
#    trousers \
#    trousers-lib \
#    which \
#    || :

  dnf -v -y remove \
    coreutils-common \
    dnf-plugins-core \
    gawk-all-langpacks \
    glibc-gconv-extra \
    libpsl \
    libssh \
    libssh-config \
    python-unversioned-command \
    rpm-plugin-systemd-inhibit \
    || :

#  dnf -v -y remove \
#    elfutils-debuginfod-client \
#    hardlink \
#    libevent \
#    libgomp \
#    openssl \
#    openssl-pkcs11 \
#    || :

  dnf -v -y remove \
    $(echo $(dnf -q repoquery --unneeded 2>/dev/null)) \
    || exit 1

  # Update and Cleanup.
  dnf -v -y update && {
    dnf -v -y clean all &&
    rm -rf /var/cache/dnf/* || :
  }

} &&
: "AL9 specific hacks." && {

  mkdir -p /var/{cache,lib}/private /var/lib/systemd/coredump &&
  chmod 700 /var/{cache,lib}/private || :

  egrep '^sgx:' &>/dev/null || {
    groupadd -r -p '!*' -g996 sgx
  } &&
  egrep '^systemd-oom:' &>/dev/null || {
    groupadd -r -p '!*' -g995 systemd-oom
  } &&
  egrep '^systemd-oom:' /etc/passwd &>/dev/null || {
    useradd -Mr -c 'systemd Userspace OOM Killer' -g995 -u995 -s/usr/sbin/nologin -d/ systemd-oom
  } && {
    sed -i "/sgx/d" /mnt/sys-root/etc/group- || :
    sed -i "/sgx/d" /mnt/sys-root/etc/gshadow- || :
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
  then sed -ri 's/^KEYMAP=.*$/KEYMAP="us"/g' "${vcnsfile}"
  else echo 'KEYMAP="us"' 1>>"${vcnsfile}"
  fi || :

  if egrep '^FONT=' "${vcnsfile}" 1>/dev/null 2>&1
  then sed -ri 's/^FONT=.*$/FONT="eurlatgr"/g' "${vcnsfile}"
  else echo 'FONT="eurlatgr"' 1>>"${vcnsfile}"
  fi || :

} &&
: "Default timezone." && {

  ( cd /etc && {
    ln -sf ../usr/share/zoneinfo/UTC ./localtime;
    : "adjtime" && {
      echo "0.0 0 0.0"
      echo "0"
      echo "UTC"
    } 1> ./adjtime
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
