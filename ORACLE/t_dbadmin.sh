#!/bin/bash
# этот скрипт удаляет логи БД, слушает логи и проводит их аудит
# ITi-Operating-Infra
# SET '_external_scn_logging_threshold_seconds'  =600
EXT_SCN_LOG_FILE=/home/oracle/scripts/t_dbadmin_log.log

echo Script $0 >> $EXT_SCN_LOG_FILE
echo ==== started on `date` ==== >> $EXT_SCN_LOG_FILE
echo >> $EXT_SCN_LOG_FILE

EXL_DB="\-MGMTDB|ASM|APX"   #Excluded INSTANCES [Will not get reported offline].

# Count Instance Numbers:
#INS_COUNT=$( ps -ef|grep pmon|grep oracle|grep -v grep|egrep -v ${EXL_DB}|wc -l )
INS_COUNT=$( ps -ef|grep pmon| grep oracle| grep -v grep|grep -Evc ${EXL_DB} )


# Exit if No DBs are running:
if [ $INS_COUNT -eq 0 ]
 then
  echo "No Database Running !">> $EXT_SCN_LOG_FILE
  exit
fi

# Exit if No oratab file location
ORATAB=/etc/oratab
if [ ! -f $ORATAB ]
  then
  echo "Not found ORATAB !">> $EXT_SCN_LOG_FILE
  exit
fi




# Loop for every Oracle Home in ORATAB file from /etc/oratab for a database
# Getting ORACLE_SID and ORACLE_HOME
for DBNAME in `ps -ef|grep [o]ra_pmon|grep -v grep|egrep -v ${EXL_DB}|awk '{print $NF}'|sed -e 's/ora_pmon_//g'|grep -v sed|grep -v "s///g"`
  do
    ORACLE_SID=`ps -ef|grep [o]ra_pmon| grep -i ${DBNAME^^}| grep -v grep|egrep -v ${EXL_DB}|awk '{print $NF}'|sed -e 's/ora_pmon_//g'|grep -v sed|grep -v "s///g"`
    ORACLE_HOME=`grep "^${DBNAME}:" /etc/oratab|cut -d: -f2 -s`
        ORA_USER=`ps -ef|grep ${ORACLE_SID}|grep pmon|grep -v grep|egrep -v ${EXL_DB}|grep -v "\-MGMTDB"|awk '{print $1}'|tail -1`
    USR_ORA_HOME=`grep -i "^${ORA_USER}:" /etc/passwd| cut -f6 -d ':'|tail -1`

# Getting ORACLE_BASE:

if [ ! -d "${ORACLE_BASE}" ]
 then
ORACLE_BASE=`cat ${ORACLE_HOME}/install/envVars.properties|grep ^ORACLE_BASE|tail -1|awk '{print $NF}'|sed -e 's/ORACLE_BASE=//g'`
export ORACLE_BASE
fi

if [ ! -d "${ORACLE_BASE}" ]
 then
ORACLE_BASE=`grep -h 'ORACLE_BASE=\/' ${USR_ORA_HOME}/.bash* ${USR_ORA_HOME}/.*profile | perl -lpe'$_ = reverse' |cut -f1 -d'=' | perl -lpe'$_ = reverse'|tail -1`
export ORACLE_BASE
fi

# Set Operating System Environment Variables
export ORACLE_SID
export ORACLE_HOME

echo "ORACLE_SID: ${ORACLE_SID}">> $EXT_SCN_LOG_FILE


# First Attempt:
OUT_LOG=$(${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" <<EOF
set pages 0 linesize 2000;
prompt
select username, DEFAULT_TABLESPACE, ACCOUNT_STATUS from dba_users  where username ='DBADMIN';
exit;
EOF
)
echo ${OUT_LOG} >> $EXT_SCN_LOG_FILE

done
# End loop read ORATAB

