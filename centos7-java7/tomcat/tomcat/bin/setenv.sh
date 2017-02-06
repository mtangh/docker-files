# setenv.sh

# service name
SERVICENAME="tomcat"

# sysconfig 
[ -r "/etc/sysconfig/tomcat" ] &&
. "/etc/sysconfig/tomcat"
[ "$SERVICENAME" != "tomcat" ] &&
[ -r "/etc/sysconfig/$SERVICENAME" ] &&
. "/etc/sysconfig/$SERVICENAME"

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
CATALINA_PID="${CATALINA_PID:-$CATALINA_RUNDIR/$SERVICENAME.pid}"

# Full path to a file where stdout and stderr will be redirected.
CATALINA_OUT="${CATALINA_OUT:-$CATALINA_LOG_DIR/catalina.out}"

# Catalina port(s)
CATALINA_PORT_SHUTDOWN="${CATALINA_PORT_SHUTDOWN:-8005}"
CATALINA_PORT_AJP="${CATALINA_PORT_AJP:-8009}"
CATALINA_PORT_HTTP="${CATALINA_PORT_HTTP:-8080}"
CATALINA_PORT_HTTPS="${CATALINA_PORT_HTTP:-8443}"

# Catalina options
CATALINA_OPTS="${CATALINA_OPTS:-}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.service.name=${SERVICENAME}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.conf.dir=${CATALINA_CNFDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.apps.dir=${CATALINA_APPDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.logs.dir=${CATALINA_LOGDIR}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.port.shutdown=${CATALINA_PORT_SHUTDOWN}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.port.http=${CATALINA_PORT_HTTP}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.port.https=${CATALINA_PORT_HTTPS}"
CATALINA_OPTS="${CATALINA_OPTS} -Dtomcat.port.ajp=${CATALINA_PORT_AJP}"
# For JDK7
CATALINA_OPTS="${CATALINA_OPTS} -Dhttps.protocols=TLSv1.2"

# Tomcat's logging config file
LOGGING_CONFIG="-Djava.util.logging.config.file=${CATALINA_BASE}/conf/logging.properties"

# Java Options
JAVA_OPTS="-server"

# Java Heap Area
JAVA_OPTS="${JAVA_OPTS} -Xmx1024m -Xms1024m"

# Java Thread stack size
JAVA_OPTS="${JAVA_OPTS} -Xss1m"

# Perm Area Size
JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=256m -XX:MaxPermSize=256m"

# Java Heap "New" Area
JAVA_OPTS="${JAVA_OPTS} -XX:NewSize=150m -XX:MaxNewSize=300m"
# Java Heap "New" Eden/Survivor Ratio
JAVA_OPTS="${JAVA_OPTS} -XX:SurvivorRatio=2"

# In a "New" generation area, if an object survives exceeding
# minor GC of the number of times of specifying with this value,
# it will move to an Old generation domain.
JAVA_OPTS="${JAVA_OPTS} -XX:MaxTenuringThreshold=32"

# The usage rate judged that a "New-Survivor" area is full
JAVA_OPTS="${JAVA_OPTS} -XX:TargetSurvivorRatio=90"

# GC Method: Enable Parallel GC 
JAVA_OPTS="${JAVA_OPTS} -XX:+UseParNewGC"
# GC Method: Concurrent Mark Sweep GC
JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC"
JAVA_OPTS="${JAVA_OPTS} -XX:+CMSClassUnloadingEnabled"
JAVA_OPTS="${JAVA_OPTS} -XX:+CMSParallelRemarkEnabled"

# Verbose GC
JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
# Verbose Class loading
#JAVA_OPTS="${JAVA_OPTS} -verbose:class"
# Print GC Options
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCTimeStamps -XX:+PrintGCDetails"
# Enable Class Histogram
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintClassHistogram"

# Enabling the JMX Agent
JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote"

# Enable Headless mode
JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"

# Complete (unsafe) will be allowed re-negotiation of the legacy is.
JAVA_OPTS="${JAVA_OPTS} -Dsun.security.ssl.allowUnsafeRenegotiation=true" 

#*eof*
