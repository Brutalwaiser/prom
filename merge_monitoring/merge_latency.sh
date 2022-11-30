#!/bin/bash

export LD_LIBRARY_PATH=/data/nrt/app/instantclient_18_3
export PATH=$PATH:$LD_LIBRARY_PATH

USER=
PASSWORD=
SERVICE=

LOG_FILE=/data/nrt/app/bash/log/mergeLatency.log
MAIL_LIST="vladimir.fomin@megafon.ru GNOC-pm-calc@megafon.ru Nikolay.Dyubin@nexign.com Eugene.Motorny@nexign.com"
#MAIL_LIST="vladimir.fomin@megafon.ru"

QUERY="set heading off
           set feedback off
           set pages 0
                   SELECT * FROM pmdata.v_nrt_mon_merge_latency t WHERE t.msg_type = 'N';"

    QRES=$(echo "$QUERY" | sqlplus -S "$USER"/"$PASSWORD"@"$SERVICE")
        echo $QRES
arrQ=(${QRES// / })
echo ${#arrQ[@]}
if [ ${#arrQ[@]} -gt 0 ]
then
	if [ $arrQ[1] -gt 2 ]
	then
		if [ $(grep WARNING /data/nrt/app/bash/latencyStatus | wc -l) == "0" ]
		then
		TRAP="NRT_MERGE_EVENT;NRT_MERGE_LATENCY;CRITICAL;Задержка технической статистики. Задержка MERGE более часа"
		SUBJECT="Problem with MERGE LATENCY on PMCDB2_PRM"
		MSGEMAIL="MERGE LATENCY is "${arrQ[1]}" hours detected at "`date`" on PMCDB2_PRM. It's time to fix it!"

		RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')

		 S="\n\n\n\nMessage from monitoring NRT"
		   BODY="${MSGEMAIL}${S}"
		   EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
		echo "WARNING" > /data/nrt/app/bash/latencyStatus
		echo $(date "+%F %H:%M:%S") "CRITICAL send" >> $LOG_FILE
		else 
		SUBJECT="Problem with MERGE LATENCY is still not fixed on PMCDB2_PRM"
		MSGEMAIL="MERGE LATENCY is "${arrQ[1]}" hours is still not fixed on PMCDB2_PRM. It's time to fix it!"

		 S="\n\n\n\nMessage from monitoring NRT"
		   BODY="${MSGEMAIL}${S}"
		   EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")

		fi
	else
		if [ $(grep OK /data/nrt/app/bash/latencyStatus | wc -l) == "0" ]
		then
		TRAP="NRT_MERGE_EVENT;NRT_MERGE_LATENCY;CLEAR;Задержка технической статистики. Задержка MERGE более часа"
		SUBJECT="Problem resolved with MERGE LATENCY on PMCDB2_PRM"
		MSGEMAIL="MERGE LATENCY is normal on PMCDB2_PRM. Well done!"

		RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')


		S="\n\n\n\nMessage from monitoring NRT"
		BODY="${MSGEMAIL}${S}"
		EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
		echo "OK" >  /data/nrt/app/bash/latencyStatus
		echo $(date "+%F %H:%M:%S") "CLEAR send" >> $LOG_FILE
		fi

	fi



#echo ${arrQ[2]}
else
#echo "CLEAR"
if [ $(grep OK /data/nrt/app/bash/latencyStatus | wc -l) == "0" ]
then
TRAP="NRT_MERGE_EVENT;NRT_MERGE_LATENCY;CLEAR;Задержка технической статистики. Задержка MERGE более часа"
SUBJECT="Problem resolved with MERGE LATENCY on PMCDB2_PRM"
MSGEMAIL="MERGE LATENCY is normal on PMCDB2_PRM. Well done!"

RES=$(curl --connect-timeout 2 -H "Content-Type: application/json" -d "{\"version\" : 1, \"community\" : \"public\", \"target\" : \"10.63.192.24:162\", \"enterprise-oid\" : \".1.3.6.1.4.1.94.1.16.1.1\", \"agent\" : \"10.99.94.196\", \"generic-trap\" : 6, \"specific-trap\" : 127, \"payload\": { \".1.3.6.1.4.1.94.1.16.1.1.0.1\" : \"$TRAP\"}}" -X POST "http://esb-vos15.megafon.ru:8723/snmp-gateway" | grep -c '{"response":"ok"}')


 S="\n\n\n\nMessage from monitoring NRT"
   BODY="${MSGEMAIL}${S}"
   EMAIL=$(echo -e "$BODY" | mailx  -r "NRT-notify@megafon.ru" -s "$SUBJECT" -S smtp=msk-smtp.megafon.ru:25 "$MAIL_LIST")
echo "OK" >  /data/nrt/app/bash/latencyStatus
echo $(date "+%F %H:%M:%S") "CLEAR send" >> $LOG_FILE
fi
fi
