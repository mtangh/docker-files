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
    sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" &&
    sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" &&
    cat "${sshd_config}"
  }

} &&
: "sshd: Enable sshd" && {

  systemctl enable sshd.service || :

} &&
: "sshd: Install pubkey for default user" && {

  if [ -s "./ssh/authorized_keys" ]
  then

    usr_name="${dockeruser:-}"
    grp_name=""
    home_dir=""
    home_ssh=""
    auth_key=""

    [ -n "${usr_name:-}" ] && {
      grp_name=$(id -gn "${usr_name}")
      home_dir=$(awk -F: '$1 == "'"${usr_name}"'" {print($6);}' 2>/dev/null)
    } || :

    [ -d "${home_dir:-X}" ] && {
      home_ssh="${home_dir}/.ssh"
      auth_key="${home_ssh}/authorized_keys"
    } || :

    [ -d "${home_ssh:-X}" ] || {
      mkdir -p "${home_ssh}" &&
      chown "${usr_name}:${grp_name:-$usr_name}" "${home_ssh}" &&
      chown 0600 "${home_ssh}"
    } || :

    [ -d "${home_ssh:-X}" -a -n "${auth_key}" ] && {
      cat "./ssh/authorized_keys" 1>>"${auth_key}"
    }

  else : "noop"
  fi

} &&
[ $? -eq 0 ]

exit $?
