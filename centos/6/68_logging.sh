#!/bin/bash -ux

if [ -n "${NO_LOGMANAGE:-}" ]
then yum -v -y update || :
else :
fi &&
if [ -n "${NO_LOGMANAGE:-}" ]
then
  echo "Without logging, skipping this instruction."
else

  : "logging: install logging" && {
    yum -v -y install rsyslog cronie logrotate
  } &&
  : "logging: Enable logging" && {
    /sbin/chkconfig --add rsyslog
    /sbin/chkconfig --levels 12345 rsyslog on
    /sbin/chkconfig --add cron
    /sbin/chkconfig --levels 12345 cron on
  } || :

fi &&
[ $? -eq 0 ]

exit $?
