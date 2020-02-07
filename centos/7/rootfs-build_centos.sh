#!/bin/bash -ux
# CentOS 7 rootfs build

[ -n "${CENTOSROOT:-}" ] || exit 1
[ -n "${RPM_GPGKEY:-}" ] || exit 1

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

: "Initialize Chroot Dir." && {

  mkdir -p "${CENTOSROOT}" &&
  rpm --root "${CENTOSROOT}" --initdb &&
  yum -v -y reinstall --downloadonly --downloaddir . centos-release &&
  rpm --root "${CENTOSROOT}" --nodeps -ivh centos-release*.rpm &&
  rpm --root "${CENTOSROOT}" --import "${CENTOSROOT}${RPM_GPGKEY}" &&
  yum -v -y \
    --installroot=${CENTOSROOT} \
    --setopt=override_install_langs=en_US.UTF-8 \
    --setopt=tsflags='nodocs' \
    install yum &&
  sed -ri \
    "/^distroverpkg=centos-.*/a override_install_langs=en_US.UTF-8" \
    "${CENTOSROOT}/etc/yum.conf" &&
  sed -ri \
    "/^override_install_langs=.*/a tsflags=nodocs" \
    "${CENTOSROOT}/etc/yum.conf" &&
  echo

} &&
: "Chroot to the environment and install some additional tools." && {

  cp -pf "/etc/resolv.conf" "${CENTOSROOT}/etc/resolv.conf" &&
  chroot "${CENTOSROOT}" /bin/bash <./rootfs-build_centos_setup.sh && {
    rm -f "${CENTOSROOT}/etc/resolv.conf" || :
  }

} &&
( : "Cleanup" && {
  cd /;
  for e in /var/log/*;
  do [ -f "$e" ] && cat /dev/null 1>"$e"; done;
  yum -v -y clean all; rm -rf /var/cache/yum/*;
} 2>/dev/null || :; ) &&
echo

exit $?
