#!/bin/bash -ux

if [ -n "${NO_SSH_LOGIN:-}" ]
then dnf -v -y update || :
else :
fi &&
if [ -n "${NO_SSH_LOGIN:-}" ]
then
  echo "Without Open SSHd, skipping this instruction."
else

  : "sshd: Install openssh-server" && {
     dnf -v -y install openssh-server
  } &&
  : "sshd: Configure sshd_config" && {

    sshd_config="/etc/ssh/sshd_config"

    [ -s "${sshd_config}" ] && {
      sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" &&
      sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" &&
      cat "${sshd_config}"
    }

  } &&
  : "sshd: Enable sshd" && {
    case "${CENTOS_VER}" in
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
  }

fi &&
[ $? -eq 0 ]

exit $?
