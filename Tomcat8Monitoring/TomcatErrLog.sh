#!/bin/bash

cat /var/log/tomcat8/catalina.out | grep -A 10 $(date +%Y-%m-%d) | grep -A 10 ORA | sed 's/ ORA/<p style="color:red;"><b>ORA<\/b><\/p>/g' | sed 's/missing expression/missing expression<br>==========<\/br>/g' > ORA_Err.html

##cat /u00/httplog/prod.gpm01.log | grep 'HTTP/1.1" 500' | awk -vDate=`date -d 'now-3 hours' +[%d/%b/%Y:%H:%M:%S` -vDate2=`date -d'23:59' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date && $4 < Date2) print $0}' > HTTP_Err.txt

tail -n 50000 /u00/httplog/prod.gpm01.log | awk -vDate=`date -d 'now-3 hours' +[%d/%b/%Y:%H:%M:%S` -vDate2=`date -d'23:59' +[%d/%b/%Y:%H:%M:%S` ' { if ($4 > Date && $4 < Date2) print $0}' | grep 'HTTP/1.1" 500' > HTTP_Err.txt

local_file_size=$(ls -l | grep HTTP_Err.txt | awk '{ print $5 }')

echo $local_file_size

if [ "$local_file_size" -ne "0" ]
   then
       echo "За последние 3 часа присутствуют ошибочные запросы. Подробная информация находится во вложениях." | mail -s "Tomcat request monitor" -a /data/jenkinsgpm/ORA_Err.html -a /data/jenkinsgpm/HTTP_Err.txt -S smtp="mail.megafon.ru:25" gpm@megafon.ru
   else
       echo "error log is empty %timestamp" > emptylog.txt
fi
