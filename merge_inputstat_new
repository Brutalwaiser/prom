#!/bin/bash

export LD_LIBRARY_PATH=/data/nrt/app/instantclient_18_3
export PATH=$PATH:$LD_LIBRARY_PATH

USER=""
PASSWORD=""
SERVICE=""

LOG_FILE=/data/nrt/app/bash/log/merge_inputstat.log
MAIL_LIST="alexander.filatov@megafon.ru pm@megafon.ru"

     #IND- INput Data - входящий поток данных для мерджинга
     IND_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT COUNT(1)
              FROM job_calculator_statictic t
              WHERE t.start_date > SYSDATE - (1/86400) * (2*3600);"

              IND_QRES=$(echo "$IND_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
                 #QRES - Query RESult
    echo "количество потоков данных для мерджинга: $IND_QRES"
     #Запрос для получения ID последней записи из таблицы инцидентов с ID операции 2
     ID_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT max(incident_id)
              FROM pmdata.Incident_Log_Table
              WHERE operation_id = 2;"

              ID_QRES=$(echo "$ID_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")

     echo "ID последней записи инцидента со входящими данными merge:$ID_QRES"
     #Запрос для получения ID статуса инцидента из таблицы инцидентов (1 - открыт, 2 - закрыт, 0- неприсвоен)
     STATUS_QUERY="set heading off
                   set feedback off
                   set pages 0
                   SELECT status_id FROM pmdata.Incident_Log_Table where incident_id=(select max(incident_id) from pmdata.Incident_Log_Table where operation_id=2);"

                   STATUS_QRES=$(echo "$STATUS_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")

                   echo "Статус инцидента:$STATUS_QRES"

  if [ $IND_QRES -eq 0 ] #проверяем отсутствие входящих потоков для мерджинга.
  then
         if [ $STATUS_QRES -eq 1 ]
         then

             echo "Предыдущий инцидент до сих пор открыт"

             SUBJECT="Отстутствие входного потока данных для merge"
             MSGEMAIL="Всё еще не решен инцидент с отсутствием входных данных merge спустя 2 часа после открытия аварии PMCDB2_PRM. Необходимо устранить проблему!"
             S="\n\n\n\nMessage from monitoring NRT"
             BODY="${MSGEMAIL}${S}"
             EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
             echo $(date "+%F %H:%M:%S") "Repeat alert" >> $LOG_FILE

             elif [ $STATUS_QRES -eq 2 ] # || [ $STATUS_QRES -eq 0 ]

             then

             echo "нет открытых инцидентов. Заводим аварию"

             TRAP="NRT_MERGE_EVENT;NRT_MRG_INPUTDATA;CRITICAL;Отсутствуют входные данные merge в течение 2-х часов;"
             SUBJECT="Отстутствие входного потока данных для merge"
             MSGEMAIL="Отсутствуют входные данные merge в течение 2-х часов на PMCDB2_PRM. Необходимо устранить проблему!"
             RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')
             S="\n\n\n\nMessage from monitoring NRT"
             BODY="${MSGEMAIL}${S}"
             EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
             echo $(date "+%F %H:%M:%S") "trap send" >> $LOG_FILE

                  TRAP_QRY="insert into pmdata.Incident_Log_Table (status_name,operation_id,status_id,reg_date,trap_send_date)
                            values ('no incoming data',2,1,sysdate,sysdate);"

                  ADDTOBASE=$(echo $TRAP_QRY | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
           echo $ADDTOBASE
        fi
   else
   ./merge_inputstat_fix.sh
   fi
