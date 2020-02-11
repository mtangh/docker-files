#!/bin/bash -ux
THIS="${BASH_SOURCE##*/}"
BASE="${THIS%.*}"
CDIR=$([ -n "${BASH_SOURCE%/*}" ] && cd "${BASH_SOURCE%/*}"; pwd)

if [ -n "${NO_SSH_LOGIN:-}" ]
then yum -v -y update || :
else :
fi &&
if [ -n "${NO_SSH_LOGIN:-}" ]
then
  echo "Without SSHd, skipping this instruction."
else

  : "sshd: Install openssh-server" && {
     yum -v -y install openssh-server
  } &&
  : "sshd: Configure sshd_config" && {
    sshd_config="/etc/ssh/sshd_config"
    [ -s "${sshd_config}" ] && {
      sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" &&
      sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" &&
      cat "${sshd_config}"
    }
  } &&
  : "sshd: Enable sshd.service" && {
    systemctl enable sshd.service || :;
  }

fi &&
[ $? -eq 0 ]

exit $?
