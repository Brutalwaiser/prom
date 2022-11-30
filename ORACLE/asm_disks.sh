#!/bin/bash
################################################################################
#                                                                              #
# Вспомогательный скрипт для заббикса, готовит данные по занятости ASM         #
# см. CCLINUX-88                                                               #
# mailto: stanislav.vlasov@megafon.ru                                          №
#                                                                  2021.08.16  #
################################################################################
# Должен запускаться по крону от oracle

umask 0022

declare -x RESULT_FILE="/tmp/ora_asm_disks.txt"

export PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin:/usr/local/sbin

# shellcheck disable=SC2155,SC2009
declare -x ORACLE_SID="$(ps -ef | grep '[p]mon_+ASM' | awk 'BEGIN{FS="_"}{printf $3}')"

if [[ -n "${ORACLE_SID}" ]]; then
  export ORAENV_ASK=NO
  # линтер падает на отсутствующем у него файле
  # shellcheck disable=SC1091
  source /usr/local/bin/oraenv >/dev/null
  echo -e "SET PAGESIZE 1000 LINESIZE 500 ECHO OFF TRIMS ON TAB OFF FEEDBACK OFF HEADING OFF;\nselect total_mb,(total_mb-free_mb),path from v\$asm_disk;\nexit" \
  | "${ORACLE_HOME}/bin/sqlplus" -S / as sysdba \
  | tail -n +2  > "${RESULT_FILE}"
else
  truncate -s 0 "${RESULT_FILE}"
fi

