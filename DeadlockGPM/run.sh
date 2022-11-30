#!/bin/bash
cd /u01/jenkinsgpm/pmgpmcollector/server/
i=`/bin/ps ax | grep "/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.275.b01-0.el7_9.x86_64/jre/bin/java -Xmx32768M -classpath /u01/jenkinsgpm/pmgpmcollector/server/PmGpmCollector.jar other.PmGpmCollector" | grep -vc grep`;
if (($i==0 ))
    then
        `nohup /usr/lib/jvm/java-1.8.0-openjdk-1.8.0.275.b01-0.el7_9.x86_64/jre/bin/java -Xmx32768M -classpath /u01/jenkinsgpm/pmgpmcollector/server/PmGpmCollector.jar other.PmGpmCollector 1> /dev/null 2>> /u01/jenkinsgpm/pmgpmcollector/log/err_trace.log`;
    else
      echo "PM/GPM Collector server works fine. If got errors, see logs";
fi
