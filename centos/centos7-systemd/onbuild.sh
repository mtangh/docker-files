#!/bin/bnah

: "Modify yum-fastestmirror" && {

  yum_fastmirror_conf="/etc/yum/pluginconf.d/fastestmirror.conf"

  [ -e "${yum_fastmirror_conf}" ] &&
  sed -ri 's/^verbose=0$/verbose=1/g' "${yum_fastmirror_conf}" &&
  sed -ri 's/^(#*)include_only=.*$/include_only=.jp,.org/g' "${yum_fastmirror_conf}" &&
  sed -ri '/^include_only=.*$/a prefer=www.ftp.ne.jp' "${yum_fastmirror_conf}" &&
  cat "${yum_fastmirror_conf}"

} &&
: "Install EPEL" && {

  yum -v -y install epel-release;

} &&
: "Install systemd" && {

  yum -v -y update &&
  yum -v -y install systemd-sysv sudo &&
  yum -v -y clean all; rm -rf /var/cache/yum/*

} &&
: "Delete systemd files" && {

  etc_systemd_sys_dir="/etc/systemd/system"
  usr_systemd_sys_dir="/usr/lib/systemd/system"

  rm -f "${etc_systemd_sys_dir}"/*.wants/* || :

  ( cd "${usr_systemd_sys_dir}" && {
      for item in
        ./multi-user.target.wants/dbus.service
        ./multi-user.target.wants/getty.target
        ./multi-user.target.wants/systemd-ask-password-wall.path
        ./multi-user.target.wants/systemd-update-utmp-runlevel.service
        ./sockets.target.wants/dbus.socket
        ./sockets.target.wants/systemd-initctl.socket
        ./sockets.target.wants/systemd-udevd-control.socket
        ./sockets.target.wants/systemd-udevd-kernel.socket
        ./sysinit.target.wants/systemd-ask-password-console.path
        ./sysinit.target.wants/systemd-udevd.service
        ./sysinit.target.wants/systemd-udev-trigger.service
        ./sysinit.target.wants/systemd-vconsole-setup.service
        ./local-fs.target.wants/systemd-remount-fs.services
      do
        rm -f "$item"
      done;
    }; ) || :

  ( cd "${usr_systemd_sys_dir}"/sysinit.target.wants && {
      for item in *
      do
        echo "$item"|
        egrep '^systemd-tmpfiles-setup.*service' ||
        rm -f "$item"
      done;
    }; ) || :

} &&
echo || exit $?

: "Cleanup" && {

  for log in $(find /var/log -type f)
  do
    [ -f "$log" ] && cat /dev/null 1>"$log"
  done;
  for log in {,/root,/tmp,/var/tmp}/*.log
  do
    rm -f "$log"
  done;
  yum -v -y clean all; rm -rf /var/cache/yum/*
  rm -rf /root/*

} || :

exit $?