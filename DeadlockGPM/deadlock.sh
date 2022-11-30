#!/bin/bash
cd /u01/jenkinsgpm/pmgpmcollector/server/

count_deadlock=$(cat /u01/jenkinsgpm/pmgpmcollector/log/PmGpmCollectorErr.log | grep 'ORA-00060: deadlock detected while waiting for resource' | wc -l)
date_d=$(date)

if [ "$count_deadlock" -gt 0 ]
then
/bin/kill $(/bin/ps aux | grep [j]enkins | grep [j]ava | grep /pmgpmcollector/ | awk '{print }') >/dev/null 2>&1
  echo "$date_d  deadlock detected and killed" >> /u01/jenkinsgpm/pmgpmcollector/log/PmGpmCollectorDeadlock.log
fi
