# setenv.sh

# Java Options
JAVA_OPTS="-server"

# Enable Headless mode
JAVA_OPTS="${JAVA_OPTS} -Djava.awt.headless=true"

# Java Heap Area
#JAVA_OPTS="${JAVA_OPTS} -Xmx1024m -Xms1024m"

# Java Thread stack size
#JAVA_OPTS="${JAVA_OPTS} -Xss1m"

# Perm Area Size
#JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=256m -XX:MaxPermSize=256m"

# Java Heap "New" Area
#JAVA_OPTS="${JAVA_OPTS} -XX:NewSize=150m -XX:MaxNewSize=300m"
# Java Heap "New" Eden/Survivor Ratio
#JAVA_OPTS="${JAVA_OPTS} -XX:SurvivorRatio=2"

# In a "New" generation area, if an object survives exceeding
# minor GC of the number of times of specifying with this value,
# it will move to an Old generation domain.
#JAVA_OPTS="${JAVA_OPTS} -XX:MaxTenuringThreshold=32"

# The usage rate judged that a "New-Survivor" area is full
#JAVA_OPTS="${JAVA_OPTS} -XX:TargetSurvivorRatio=90"

# GC Method: Enable Parallel GC 
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseParNewGC"
# GC Method: Concurrent Mark Sweep GC
#JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC"
#JAVA_OPTS="${JAVA_OPTS} -XX:+CMSClassUnloadingEnabled"
#JAVA_OPTS="${JAVA_OPTS} -XX:+CMSParallelRemarkEnabled"

# Verbose GC
JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
# Verbose Class loading
#JAVA_OPTS="${JAVA_OPTS} -verbose:class"
# Print GC Options
#JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCTimeStamps -XX:+PrintGCDetails"
# Enable Class Histogram
#JAVA_OPTS="${JAVA_OPTS} -XX:+PrintClassHistogram"

# Enabling the JMX Agent
#JAVA_OPTS="${JAVA_OPTS} -Dcom.sun.management.jmxremote"

# Complete (unsafe) will be allowed re-negotiation of the legacy is.
#JAVA_OPTS="${JAVA_OPTS} -Dsun.security.ssl.allowUnsafeRenegotiation=true" 

#*eof*
