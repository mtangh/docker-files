#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

if [ "${LOGROTATION:-YES}" != "YES" ]
then
  echo "Without logrotate, skipping this instruction."
  exit 0
fi

: "logrotate: install logrotate" && {

  yum -v -y update || :
  yum -v -y install logrotate

} &&
: "logrotate: SetUp systemd files" && {

  systemd_sys_dir="/etc/systemd/system"

  [ -d "${systemd_sys_dir}" ] || {
    mkdir -p "${systemd_sys_dir}" &&
    chown root:root "${systemd_sys_dir}" &&
    chmod 0755 "${systemd_sys_dir}" ||
    exit 1
  } &&
  : "logrotate: logrotate.service" && {

cat <<_EOD_
# Systemd unit file for logrotate.service

[Unit]
Description=logrotate

[Service]
Type=simple

# Exec Start,Stop,etc...
ExecStart=/etc/cron.daily/logrotate

_EOD_

  } 1>"${systemd_sys_dir}/logrotate.service" &&
  : "logrotate: logrotate.timer" && {

cat <<_EOD_
# Systemd unit file for logrotate.timer

[Unit]
Description=Daily Log Rotation

[Timer]
OnCalendar=*-*-* 02:00:00
Persistent=true

[Install]
WantedBy=timers.target

_EOD_
  } 1>"${systemd_sys_dir}/logrotate.timer" &&
  chown root:root "${systemd_sys_dir}"/logrotate.* &&
  chmod 0644 "${systemd_sys_dir}"/logrotate.*

} &&
: "logrotate: Enable logrotate.timer" && {

  systemctl enable logrotate.timer || :

} &&
[ $? -eq 0 ]

exit $?
