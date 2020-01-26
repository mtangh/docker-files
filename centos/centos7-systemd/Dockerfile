#
# centos:centos7-systemd
#
#@  DOCKER_CONTAINER=""
#@  DOCKER_IMAGE_TAG="centos:centos7-systemd"
#@  DOCKER_BUILDOPTS=""
#@  DOCKER_BOOT_OPTS=""
#
FROM centos:centos7-minimal AS build-stage

# Labels
LABEL \
 build-stage="true"

# Shell
SHELL \
 [ "/bin/bash", "-u", "-x", "-c" ]

# Reset Workdir
WORKDIR \
 /

# CentOS 7 with systemd
FROM scratch AS centos7-systemd-stage

# Labels
LABEL \
 name="CentOS 7 with Systemd" \
 vendor="UGOOLE.ORG" \
 maintainer="MT" \
 license=""

# Labels for build
LABEL \
 build-date="" \
 docker.build.options=""

# Reset Workdir
WORKDIR \
 /

# COPY from build-stage
COPY \
 --from=build-stage / /

# ONBUILD: System locale
ONBUILD \
ARG \
 CONTAINER_LANGUAGE="en_US.UTF-8"

# ONBUILD: keymap and timezone
ONBUILD \
ARG \
 CONTAINER_KEYBOARD="jp106"

# ONBUILD: timezone
ONBUILD \
ARG \
 CONTAINER_TIMEZONE="Asia/Tokyo"

# ONBUILD: root password
ONBUILD \
ARG \
 CONTAINER_ROOTPSWD=""

# ONBUILD: Default login
ONBUILD \
ARG \
 DOCKER_UID=500
ONBUILD \
ARG \
 DOCKERUSER=dockeruser
ONBUILD \
ARG \
 DOCKERPASS=""

# ONBUILD: sshd
ONBUILD \
ARG \
 WITHOUT_SSHD_LOGIN=""

# ONBUILD: logrotate
ONBUILD \
ARG \
 WITHOUT_LOG_ROTATE=""

# ONBUILD: Set Workdir
ONBUILD \
ARG \
 BUILDDIR=/root/docker-container-build
ONBUILD \
WORKDIR \
 ${BUILDDIR}

# ONBUILD: Build script
ONBUILD \
COPY \
 onbuild.* ${BUILDDIR}/

# ONBUILD: SetUp
ONBUILD \
RUN \
 set -ux ; \
 : "ONBUILD: Init" && { \
  language="${CONTAINER_LANGUAGE:-en_US.UTF-8}"; \
  keyboard="${CONTAINER_KEYBOARD:-jp106}"; \
  timezone="${CONTAINER_TIMEZONE:-Asia/Tokyo}"; \
  rootpswd="${CONTAINER_ROOTPSWD:-}"; \
  if [ -e "./onbuild.rc" ]; \
  then . "./onbuild.rc" || exit 1; \
  fi || :; \
 }; \
 : "ONBUILD: SetUp system locale: ${language}" && { \
  lc_cntr=$(echo "${language}"|cut -d. -f1); lc_cntr="${lc_cntr:-en_US}"; \
  lc_lang=$(echo "${language}"|cut -d. -f2); lc_lang="${lc_lang:-UTF-8}"; \
  localedef -v -c -i "${lc_cntr}" -f "${lc_lang}" "${lc_cntr}.${lc_lang}"; \
  localectl set-locale "LANG=${lc_cntr}.${lc_lang}" || \
  echo "LANG=${lc_cntr}.${lc_lang}" 1>/etc/locale.conf; \
 }; \
 : "ONBUILD: keymap: keyboard=${keyboard}" && { \
  if [ -e "/etc/vconsole.conf" ]; \
  then . /etc/vconsole.conf; fi; \
  if [ -z "${KEYMAP:-}" ]; \
  then echo 'KEYMAP='"${keyboard}" 1>>/etc/vconsole.conf && . /etc/vconsole.conf; fi; \
  if [ "${KEYMAP:-}" != "${keyboard}" ]; \
  then sed -ri 's/^KEYMAP=.*$/KEYMAP="'"${keyboard}"'"/g' /etc/vconsole.conf; fi; \
 }; \
 : "ONBUILD: timezone: timezone=${timezone}" && { \
  if [ -e "/usr/share/zoneinfo/${timezone}" ]; \
  then \
   { [ -e "/etc/localtime" ] && mv -f /etc/localtime{,.ORIG} || :; } && \
   ln -sf "/usr/share/zoneinfo/${timezone}" /etc/localtime; \
  fi; \
  ls -l /etc/localtime; \
 }; \
 : "ONBUILD: Set root password" && { \
  if [ -n "${rootpswd:-}" ]; \
  then echo "${rootpswd}" |passwd --stdin root; passwd -l root; \
  fi; \
 }; \
 : "ONBUILD: SetUp default user" && { \
  if [ -n "${DOCKERUSER:-}" ]; \
  then \
   docker_uid="${DOCKER_UID:-500}"; \
   dockeruser="${DOCKERUSER:-dockeruser}"; \
   dockerpass="${DOCKERPASS:-}"; \
   groupadd -g "${docker_uid}" "${dockeruser}" && \
   useradd -u "${docker_uid}" -g "${dockeruser}" -m "${dockeruser}" && \
   if [ -n "${dockerpass:-}" ]; \
   then echo "${dockeruser}:${dockerpass}"; \
   else echo "${dockeruser}:$(dd if=/dev/urandom count=50 2>/dev/null|md5sum)"; \
   fi |chpasswd; \
   sudoers="/etc/sudoers"; \
   newline="# For docker user\n${dockeruser}\tALL=(ALL)\tNOPASSWD: ALL"; \
   sed -ri '/^root[ \t]*ALL.*$/a '"${newline}" "${sudoers}"; \
  fi; \
 }; \
 if [ -n "${WITHOUT_SSHD_LOGIN:-}${WITHOUT_LOG_ROTATE:-}" ]; \
 then yum -v -y update; \
 fi; \
 if [ -n "${WITHOUT_SSHD_LOGIN:-}" ]; \
 then echo "Without SSHd, skipping this instruction."; \
 else \
  : "ONBUILD: sshd: Install openssh-server" && { \
   yum -v -y install openssh-server; \
  } && \
  : "ONBUILD: sshd: Configure sshd_config" && { \
   sshd_config="/etc/ssh/sshd_config"; \
   [ -s "${sshd_config}" ] && { \
    sed -ri 's/^#PermitRootLogin[ ]*yes/PermitRootLogin yes/' "${sshd_config}" && \
    sed -ri 's/^UsePAM yes/UsePAM no/' "${sshd_config}" && \
    cat "${sshd_config}"; }; \
  } && \
  : "ONBUILD: sshd: Enable sshd.service" && { \
   systemctl enable sshd.service || :; \
  }; \
 fi; \
 if [ -n "${WITHOUT_LOG_ROTATE:-}" ]; \
 then echo "Without logrotate, skipping this instruction."; \
 else \
  : "ONBUILD: logrotate: install logrotate" && { \
   yum -v -y install logrotate; \
  } && \
  : "ONBUILD: logrotate: SetUp systemd files" && { \
   systemd_sys_dir="/etc/systemd/system"; \
   [ -d "${systemd_sys_dir}" ] || { \
    mkdir -p "${systemd_sys_dir}" && \
    chown root:root "${systemd_sys_dir}" && \
    chmod 0755 "${systemd_sys_dir}"; \
   }; \
   : && { \
    echo '# Systemd unit file for logrotate.service' && \
    echo '' && \
    echo '[Unit]' && \
    echo 'Description=logrotate' && \
    echo '' && \
    echo '[Service]' && \
    echo 'Type=simple' && \
    echo '' && \
    echo '# Exec Start,Stop,etc...' && \
    echo 'ExecStart=/etc/cron.daily/logrotate' && \
    echo ''; \
   } 1>"${systemd_sys_dir}/logrotate.service"; \
   : && { \
    echo '# Systemd unit file for logrotate.timer' && \
    echo '' && \
    echo '[Unit]' && \
    echo 'Description=Daily Log Rotation' && \
    echo '' && \
    echo '[Timer]' && \
    echo 'OnCalendar=*-*-* 02:00:00' && \
    echo 'Persistent=true' && \
    echo '' && \
    echo '[Install]' && \
    echo 'WantedBy=timers.target' && \
    echo ''; \
   } 1>"${systemd_sys_dir}/logrotate.timer"; \
   chown root:root "${systemd_sys_dir}"/logrotate.* && \
   chmod 0644 "${systemd_sys_dir}"/logrotate.*; \
  } && \
  : "ONBUILD: logrotate: Enable logrotate.timer" && { \
   systemctl enable logrotate.timer || : ; \
  }; \
 fi; \
 if [ -s "./onbuild.sh" ]; \
 then echo "Not found 'onbuild.sh', skipping this instruction."; \
 else \
  : "ONBUILD: BUILD-SCRIPTS: Execute './onbuild.sh'" && { \
   bash -ux "./onbuild.sh" || exit 1; \
  }; \
 fi; \
 : "ONBUILD: Cleanup" && { \
  cd && { ; \
   for log in $(find /var/log -type f); \
   do [ -f "$log" ] && cat /dev/null 1>"$log"; done; \
   for log in {,/var}/tmp/*.log; do rm -f "$log"; done; \
   yum -v -y clean all; rm -rf /var/cache/yum/*; \
   [ -d "${BUILDDIR:--}" ] && rm -rf "${BUILDDIR}" || :; \
   rm -rf /root/*; \
  }; \
 } 2>/dev/null || :; \
 echo;

# ONBUILD: Reset Workdir
ONBUILD \
WORKDIR \
 /

# Labels for run
LABEL \
 docker.run.options="-d -P -h centos7-systemd --privileged" \
 docker.run.confirm-startup=""

# STOP SIGNAL
STOPSIGNAL SIGINT

## Publish a container's port(s) to the host
#EXPOSE 22

# Volume
VOLUME [ "/sys/fs/cgroup" ]

# Start /sbin/init
CMD [ "/sbin/init" ]

