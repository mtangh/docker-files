#!/bin/bash
set -ux -o errtrace -o functrace -o pipefail

if [ "${LOGROTATION:-YES}" != "YES" ]
then
  echo "Without logging, skipping this instruction."
  exit 0
fi

: "logging: install logging" && {

  yum -v -y update || :
  yum -v -y install rsyslog cronie logrotate

} &&
: "logging: Enable logging" && {

  /sbin/chkconfig --add rsyslog &&
  /sbin/chkconfig --levels 12345 rsyslog on || :

  /sbin/chkconfig --add cron &&
  /sbin/chkconfig --levels 12345 cron on || :

} &&
[ $? -eq 0 ]

exit $?
