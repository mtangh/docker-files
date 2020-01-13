#!/bin/bash -ux

remirepo=remi-php56

curl -sL -o remi.rpm "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm" &&
rpm -Uvh remi.rpm &&
yum -v -y update &&
yum -v -y install --enablerepo=${remirepo} php php-devel php-pear &&
yum -v -y install --enablerepo=${remirepo} php-mbstring php-pdo php-gd &&
yum -v -y install --enablerepo=${remirepo} php-xml php-json php-mcrypt php-pecl-zip &&
yum -v -y clean all

exit $?
