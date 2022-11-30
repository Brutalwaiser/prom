#!/bin/sh

find /var/log/tomcat8/ -type f -name "*.log" -o -name "*.gz" -o -name "*.txt" | sort -V | xargs tar -zcvf /var/log/tomcat8/tomcat_logs_"$(date +"%m-%Y")".tgz  ##| echo "archive created suc$
find /var/log/tomcat8/ -type f -name "*.log" -o -name "*.gz" -o -name "*.txt" | xargs rm -f
