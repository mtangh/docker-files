#!/bin/bash -ux

remirepo=remi-php70

yum -v -y update &&
: "PHP" && {
  curl -sL -o remi.rpm "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm" &&
  rpm -Uvh remi.rpm &&
  yum -v -y install --enablerepo=${remirepo} php php-devel php-pear &&
  yum -v -y install --enablerepo=${remirepo} php-mbstring php-pdo php-gd &&
  yum -v -y install --enablerepo=${remirepo} php-xml php-json php-mcrypt php-pecl-zip &&
  echo
} &&
: "MySQL" && {
 curl -sL -o mysql.rpm "https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm" &&
 rpm -Uvh mysql.rpm &&
 yum -v -y update &&
 yum -v -y install mysql-community-server &&
 yum -v -y install --enablerepo=${remirepo} php-mysqlnd &&
systemctl enable mysqld.service &&
 echo
} &&
yum -v -y clean all

exit $?
