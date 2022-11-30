#!/bin/bash

export LD_LIBRARY_PATH=/data/nrt/app/instantclient_18_3
export PATH=$PATH:$LD_LIBRARY_PATH

USER=''
PASSWORD=''
SERVICE=''

LOG_FILE=/data/nrt/app/bash/log/merge_inputstat.log
MAIL_LIST="alexander.filatov@megafon.ru pm@megafon.ru"

     #PROC- process - процесс merge manager
     PROC_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT COUNT (1)
              FROM dba_scheduler_running_jobs
              WHERE job_name = 'MERGE_MANAGER';"

              PROC_QRES=$(echo "$PROC_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
                 #QRES - Query RESult
     echo "Количество запущенных процессов merge-manager: $PROC_QRES"

     ID_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT max(incident_id)
              FROM pmdata.incident_log_table
              WHERE operation_id = 1;"

              ID_QRES=$(echo "$ID_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")

     echo  "ID операции merge-manager из справочника: $ID_QRES"

     STATUS_QUERY="set heading off
                   set feedback off
                   set pages 0
                   SELECT status_id FROM pmdata.Incident_Log_Table where incident_id=(select max(incident_id) from pmdata.Incident_Log_Table where operation_id=1);"
                   STATUS_QRES=$(echo "$STATUS_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
                   echo "Статус операции:$STATUS_QRES"

 if [ $PROC_QRES -eq 0 ] #проверяем отсутствие процессов мердж-менеджера
 then
         if [ $STATUS_QRES -eq 1 ]
         then

             echo "инцидент до сих пор открыт"

             SUBJECT="Merge manager неактивен"
             MSGEMAIL="Всё еще не решен инцидент с отсутствием процесса merge manager спустя 1 час после открытия аварии PMCDB2_PRM. Необходимо устранить проблему!"
             S="\n\n\n\nMessage from monitoring NRT"
             BODY="${MSGEMAIL}${S}"
             EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
             echo $(date "+%F %H:%M:%S") "Repeat alert" >> $LOG_FILE

             elif [ $STATUS_QRES -eq 2 ] #сценарий, в котором открывается трап

             then

             echo "нет открытых инцидентов. Заводим аварию"

             TRAP="NRT_MERGE_EVENT;NRT_MRGPROC_NULL;CRITICAL;Отсутствуют запущенные процессы merge manager"
             SUBJECT="Отстутствие процесса merge"
             MSGEMAIL="Отсутствует активный процесс merge manager на PMCDB2_PRM. Необходимо устранить проблему!"
             RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')
             S="\n\n\n\nMessage from monitoring NRT"
             BODY="${MSGEMAIL}${S}"
             EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
             echo $(date "+%F %H:%M:%S") "trap send" >> $LOG_FILE

                  TRAP_QRY="insert into pmdata.Incident_Log_Table (status_name,operation_id,status_id,reg_date,trap_send_date)
                            values ('no merge manager process',1,1,sysdate,sysdate);"

                  ADDTOBASE=$(echo $TRAP_QRY | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
           echo $ADDTOBASE
        fi
   else
echo "Процесс merge-manager работает. Проверяем необходимость клира"
./merge_null_fix.sh
fi
