#!/bin/bash

export LD_LIBRARY_PATH=/data/nrt/app/instantclient_18_3
export PATH=$PATH:$LD_LIBRARY_PATH

USER=
PASSWORD=
SERVICE=

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

echo "Редирект сработал, выполняется скрипт клира"
     #Запрос для получения ID последней записи из таблицы инцидентов
     ID_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT max(incident_id)
              WHERE operation_id = 2
              FROM pmdata.Incident_Log_Table;"

              ID_QRES=$(echo "$ID_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")

#     echo $ID_QRES
     #Запрос для получения ID статуса ПОСЛЕДНЕГО инцидента из таблицы инцидентов (1 - открыт, 2 - закрыт)
     STATUS_QUERY="set heading off
              set feedback off
              set pages 0
              SELECT status_id
              FROM  pmdata.Incident_Log_Table
              where incident_id=(select max(incident_id) from pmdata.Incident_Log_Table where operation_id=2);"

              STATUS_QRES=$(echo "$STATUS_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")

     #echo $STATUS_QRES

  if [ $STATUS_QRES == "1" ] && [ $IND_QRES -ge "1" ]
  then
      echo "начали клирить"
             TRAP="NRT_MERGE_EVENT;NRT_MRG_INPUTDATA;CLEAR;Отсутствуют входные данные merge в течении 2-х часов;"
             SUBJECT="Отстутствие входного потока данных для merge"
             MSGEMAIL="Проблема устранена! Появились входящие потоки данных для merge."
             RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')             S="\n\n\n\nMessage from monitoring NRT"
             BODY="${MSGEMAIL}${S}"
             EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
             echo $(date "+%F %H:%M:%S") "trap CLEAR" >> $LOG_FILE

          CLEAR_QRY="UPDATE pmdata.Incident_Log_Table
                     SET status_id = 2, trap_close_date = sysdate
                     WHERE incident_id=(select max(incident_id) from pmdata.Incident_Log_Table where operation_id = 2);"

          CLEARING=$(echo $CLEAR_QRY | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
          echo $CLEARING
   else
       echo "клирить нечего"
       echo $(date "+%F %H:%M:%S") "it's allright" >> $LOG_FILE
   fi
