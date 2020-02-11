#!/bin/bash -ux
# CentOS built rootfs image
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

[ -n "${CENTOS_VER:-}" ] || exit 1
[ -n "${CENTOSROOT:-}" ] || exit 1

#
# - Create a folder for our new root structure
# - Initialize RPM database
# - Download and install the centos-release package
# - Install yum without docs and install only the
#   english language files during the process
# - Configure yum to avoid installing of docs and
#   other language files than english generally
# - Chroot to the environment and install some additional tools
#

# Enable yum plugins
cat /etc/yum.conf |
sed -r -e 's/^(#*)plugins=[01]$/plugins=1/g' |
cat 1>/etc/yum.conf.tmp &&
mv -f /etc/yum.conf{.tmp,} &&{
  echo
  echo "[/etc/yum.conf]"
  cat /etc/yum.conf
  echo
} || :

# Modify yum-fastestmirror
yum_plgcnf="/etc/yum/pluginconf.d"
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

: "Initialize Chroot Dir." && {

  rpm_gpgkey="/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-${CENTOS_VER}"

  mkdir -p "${CENTOSROOT}" &&
  rpm --root "${CENTOSROOT}" --initdb &&
  yum -v -y reinstall --downloadonly --downloaddir . centos-release &&
  rpm --root "${CENTOSROOT}" --nodeps -ivh centos-release*.rpm &&
  rpm --root "${CENTOSROOT}" --import "${CENTOSROOT}${rpm_gpgkey}" &&
  yum -v -y \
    --installroot=${CENTOSROOT} \
    --setopt=override_install_langs=en_US.UTF-8 \
    --setopt=tsflags='nodocs' \
    install yum

} &&
: "Chroot to the environment and install some additional tools." && {

  cp -pf {,"${CENTOSROOT}"}/etc/resolv.conf && {

    for build_sh in ./scripts.d/[0-9][0-9]_*.sh
    do
      [ -e "${build_sh}" ] &&
      chroot "${CENTOSROOT}" /bin/bash <"${build_sh}" ||
      exit 1
    done

  } &&
  rm -f "${CENTOSROOT}/etc/resolv.conf" || :

} &&
: "Cleanup" && {
  cd /;
  for lf in /var/log/*;
  do [ -f "${lf}" ] && cat /dev/null 1>"${lf}"; done;
  yum -v -y clean all; rm -rf /var/cache/yum/*;
} 2>/dev/null || : &&
: "Done."

exit $?
