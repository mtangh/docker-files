#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

if [ "${ENABLE_SSHD:-YES}" != "YES" ]
then
  echo "Without Open SSHd, skipping this instruction."
  exit 0
fi

YUM=yum

case "${CENTOS_VER:-X}" in
8*)
  YUM=dnf
  ;;
*)
  ;;
esac

: "sshd: Install openssh-server" && {

  $YUM -v -y update || :
  $YUM -v -y install openssh-server

} &&
: "sshd: Configure sshd_config" && {

  sshd_config="/etc/ssh/sshd_config"

  [ -s "${sshd_config}" ] && {
    sed -ri 's/^#PermitRootLogin[[:space:]]+.+$/PermitRootLogin yes/' "${sshd_config}" &&
    sed -ri 's/^UsePAM[[:space:]]+yes/UsePAM no/' "${sshd_config}" &&
    cat "${sshd_config}"
  }

} &&
: "sshd: Enable sshd" && {

  case "${CENTOS_VER:-X}" in
  5*|6*)
    /sbin/chkconfig --add sshd || :
    /sbin/chkconfig --levels 2345 sshd on || :
    ;;
  7*|8*)
    systemctl enable sshd.service || :
    ;;
  *)
    ;;
  esac

} &&
[ $? -eq 0 ]

exit $?
