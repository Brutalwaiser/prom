#!/bin/bash

export LD_LIBRARY_PATH=/data/nrt/app/instantclient_18_3
export PATH=$PATH:$LD_LIBRARY_PATH 

USER=
PASSWORD=
SERVICE=

LOG_FILE=/data/nrt/app/bash/log/mergeError.log
action_trap() {

    QUERY="set heading off
           set feedback off
           set pages 0
           select ID from pmdata.job_calculator_statictic
            where start_date > sysdate - 1
            and msg_type = 'E'
            AND trap_date is null;"

    echo "$QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
}
action_trap_end() {

    QUERY="set heading off
           set feedback off
           set pages 0
            SELECT ID
            FROM pmdata.job_calculator_statictic t
            WHERE start_date > sysdate - 1
            AND msg_type IN ('E')
            AND EXISTS (SELECT 1 FROM pmdata.job_calculator_statictic tt WHERE tt.tmp_table_name = t.tmp_table_name AND msg_type = 'I')
            AND TRAP_DATE_END is null;"

    echo "$QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
}
send_trap() {
#    MAIL_LIST="vladimir.fomin@megafon.ru GNOC-pm-calc@megafon.ru nikolay.dyubin@nexign-systems.com Eugene.Motorny@nexign.com"
    MAIL_LIST="alexander.filatov@megafon.ru"
    if [ $2 == "START" ]; then
        TRAP="NRT_MERGE_EVENT;NRT_MERGE_FAIL;CRITICAL;(ID = $1) Отсутствует техническая статистика за последние сутки"
        SUBJECT="Problem with merge ID = $1 on PMCDB2_PRM"
        MSGEMAIL="Merge ID = $1 problem started at "`date`" on PMCDB2_PRM. It's time to fix it!"
    elif [ $2 == "END" ]; then
        TRAP="NRT_MERGE_EVENT;NRT_MERGE_FAIL;CLEAR;(ID = $1) Отсутствует техническая статистика за последние сутки"
        SUBJECT="Problem resolved with merge ID = $1 on PMCDB2_PRM"
        MSGEMAIL="Merge ID = $1 problem resolved at "`date`" on PMCDB2_PRM. Well done!"
    fi
    #RES=0
    RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')
#RES=1
   #RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"$FMPROBE:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"error":0,"status":"ok"}')
    S="\n\n\n\nMessage from monitoring NRT"
    BODY="${MSGEMAIL}${S}"
    EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
#echo $2
#echo $RES

}

sent_trap_start() {
#echo $1
#echo "update"
    QUERY="update job_calculator_statictic
              set trap_date = sysdate
            where id in ($1);"

    echo "$QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
    #добавление данных в новый справочник инцидентов
    LOG_QUERY="insert into pmdata.incident_Log_Table (status_name,operation_id,status_id,trap_send_date)
               values ($1,4,1,sysdate);"

    echo "$LOG_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
}

sent_trap_end() {
    QUERY="update job_calculator_statictic
              set trap_date_end = sysdate
            where id in ($1);"
    echo "$QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
    echo $1
    LOG_QUERY="update pmdata.incident_Log_Table
    set status_id = 2,trap_close_date = sysdate where status_name in ($1);"
    echo "$LOG_QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE"
}

log() {
    if [ $2 == "1" ]; then
        MSG="sent successfully"
    else
        MSG="not sent"
    fi
    echo $(date "+%F %H:%M:%S") Trap ID = $1 "$MSG" >> $LOG_FILE
}

main() {

    while read -a line; do
        send_trap ${line[0]} START
        if [ $RES -eq 1 ]; then
         ID_LIST+="${line[0]}",
       echo $ID_LIST
        fi
        log ${line[0]} $RES
    done < <(action_trap)

        ID_LIST=${ID_LIST::-1}
#echo "arg = "$1
#    echo "ID_LIST="$ID_LIST

    if [ -n "$ID_LIST" ]; then
        sent_trap_start "$ID_LIST"
    fi
    while read -a line; do
        send_trap ${line[0]} END
        if [ $RES -eq 1 ]; then
         ID_LIST_END+="${line[0]}",
        fi
        log ${line[0]} $RES
    done < <(action_trap_end)
    ID_LIST_END=${ID_LIST_END::-1}
#    echo ID_LIST_END=$ID_LIST_END
    if [ -n "$ID_LIST_END" ]; then
        sent_trap_end "$ID_LIST_END"
    fi
}

main;


