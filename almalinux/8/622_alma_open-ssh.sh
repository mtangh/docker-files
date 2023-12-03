#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

dockeruser="${DOCKERUSER:-dockeruser}"

if [ "${ENABLE_SSHD:-YES}" != "YES" ]
then
  echo "Without Open SSHd, skipping this instruction."
  exit 0
fi

: "sshd: Install openssh-server" && {

  dnf -v -y update || :
  dnf -v -y install openssh-server

} &&
: "sshd: Configure sshd_config" && {

  sshd_config="/etc/ssh/sshd_config"

  [ -s "${sshd_config}" ] && {
    sed -ri 's/^#PermitRootLogin[[:space:]]+.+$/PermitRootLogin yes/' "${sshd_config}" &&
    sed -ri 's/^(#|)UsePAM[[:space:]]+.+$/UsePAM no/' "${sshd_config}" &&
    cat "${sshd_config}"
  }

} &&
: "sshd: Enable sshd" && {

  systemctl enable sshd.service || :

} &&
[ $? -eq 0 ]

exit $?
