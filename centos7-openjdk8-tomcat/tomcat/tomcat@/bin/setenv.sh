# setenv.sh

# Instance name
INSTANCENAME="${INSTANCENAME:-tomcat}"

# sysconfig 
[ -r "/etc/sysconfig/tomcat" ] &&
. "/etc/sysconfig/tomcat"
[ -r "/etc/sysconfig/tomcat@${INSTANCENAME}" ] &&
. "/etc/sysconfig/tomcat@${INSTANCENAME}"

# Catalina base
[ -z "$CATALINA_BASE" ] &&
CATALINA_BASE="${CATALINA_HOME}"

# Catalina directories
CATALINA_CNFDIR="${CATALINA_CNFDIR:-$CATALINA_BASE/conf}"
CATALINA_APPDIR="${CATALINA_APPDIR:-$CATALINA_BASE/webapps/deploy}"
CATALINA_LOGDIR="${CATALINA_LOGDIR:-$CATALINA_BASE/logs}"
CATALINA_RUNDIR="${CATALINA_RUNDIR:-$CATALINA_BASE/run}"
# Directory path location of temporary directory the JVM should
# use (java.io.tmpdir).
CATALINA_TMPDIR="${CATALINA_TMPDIR:-$CATALINA_BASE/temp}"

# Path of the file which should contains the pid of catalina startup
# java process, when start (fork) is used
CATALINA_PID="${CATALINA_PID:-$CATALINA_RUNDIR/$INSTANCENAME.pid}"

# Full path to a file where stdout and stderr will be redirected.
CATALINA_OUT="${CATALINA_OUT:-$CATALINA_LOGDIR/catalina.out}"

# Catalina port(s)
CATALINA_PORT_SHUTDOWN="${CATALINA_PORT_SHUTDOWN:-8005}"
CATALINA_PORT_AJP="${CATALINA_PORT_AJP:-8009}"
CATALINA_PORT_HTTP="${CATALINA_PORT_HTTP:-8080}"
CATALINA_PORT_HTTPS="${CATALINA_PORT_HTTP:-8443}"

# Catalina options
CATALINA_OPTS="${CATALINA_OPTS:-}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.instance.name=${INSTANCENAME}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.conf.dir=${CATALINA_CNFDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.webapps.dir=${CATALINA_APPDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.logs.dir=${CATALINA_LOGDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.port.shutdown=${CATALINA_PORT_SHUTDOWN}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.port.ajp=${CATALINA_PORT_AJP}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.port.http=${CATALINA_PORT_HTTP}"
CATALINA_OPTS="${CATALINA_OPTS} -Dcatalina.port.https=${CATALINA_PORT_HTTPS}"

# Tomcat's logging config file
LOGGING_CONFIG="${LOGGING_CONFIG:--Djava.util.logging.config.file=$CATALINA_BASE/conf/logging.properties}"

# Java Options
[ -r "${CATALINA_BASE}/bin/JAVA_OPTS.sh" ] &&
. "${CATALINA_BASE}/bin/JAVA_OPTS.sh"

#*eof*
