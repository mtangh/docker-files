#!/bin/bash -ux

if [ -n "${DOCKERUSER:-}" ]
then

  : "ONBUILD: SetUp default user" && {

    docker_uid="${DOCKER_UID:-500}"
    dockeruser="${DOCKERUSER:-dockeruser}"
    dockerpass="${DOCKERPASS:-}"

    [ -n "${dockerpass:-}" ] || {
      dockerpass=$({
        dd "if=/dev/urandom" count=50 |
        md5sum;
        }; )
    }

    groupadd -g "${docker_uid}" "${dockeruser}" &&
    useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && {
      echo "${dockerpass}" |
      passwd --stdin "${dockeruser}"
    } || exit 1

    sudoerfile="/etc/sudoers"
    insertline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"

    sed -ri \
      '/^root[ \t]*ALL.*$/a '"${insertline}" \
      "${sudoerfile}" || exit 1

  }

fi &&
if [ -n "${NO_SSH_LOGIN:-}${NO_LOGROTATE:-}" ]
then
  yum -v -y update || :
fi &&
if [ -n "${NO_SSH_LOGIN:-}" ]
then
  echo "ONBUILD: Without SSHd, skipping this instruction."
else

  : "ONBUILD: sshd: Install openssh-server" && {
     yum -v -y install openssh-server
  } &&
  : "ONBUILD: sshd: Configure sshd_config" && {
    sshd_config="/etc/ssh/sshd_config"
    [ -s "${sshd_config}" ] && {
      sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" &&
      sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" &&
      cat "${sshd_config}"
    }
  } &&
  : "ONBUILD: sshd: Enable sshd.service" && {
    systemctl enable sshd.service || :;
  }

fi &&
if [ -n "${NO_LOGROTATE:-}" ]
then
  echo "ONBUILD: Without logrotate, skipping this instruction."
else

  : "ONBUILD: logrotate: install logrotate" && {
    yum -v -y install logrotate
  } &&
  : "ONBUILD: logrotate: SetUp systemd files" && {
    systemd_sys_dir="/etc/systemd/system"
    [ -d "${systemd_sys_dir}" ] || {
      mkdir -p "${systemd_sys_dir}" &&
      chown root:root "${systemd_sys_dir}" &&
      chmod 0755 "${systemd_sys_dir}" || exit 1
    }
    : && {
      cat <<_EOF_
# Systemd unit file for logrotate.service

[Unit]
Description=logrotate

[Service]
Type=simple

# Exec Start,Stop,etc...
ExecStart=/etc/cron.daily/logrotate

_EOF_
    } 1>"${systemd_sys_dir}/logrotate.service"
    : && {
      cat <<_EOF_
# Systemd unit file for logrotate.timer

[Unit]
Description=Daily Log Rotation

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target

_EOF_
    } 1>"${systemd_sys_dir}/logrotate.timer"
    chown root:root "${systemd_sys_dir}"/logrotate.*
    chmod 0644 "${systemd_sys_dir}"/logrotate.*
  } &&
  : "ONBUILD: logrotate: Enable logrotate.timer" && {
    systemctl enable logrotate.timer || :
  }

fi &&
[ $? -eq 0 ]

