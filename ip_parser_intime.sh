#!/bin/bash
#
# Считываем кол-во запросов по IP адресам из лога Nginx
# Без параметров количество запосов по IP, за последние 120 минут
# Опционально 1 параметром - время за которое выводим данные лога, в минутах
#
 
export LC_ALL=en_US.UTF-8
export LC_NUMERIC=C
 
if [ -z "$1" ]
then
    MNT="120"
else
    MNT="$1"
fi
 
# Максимальное количество IP в выводе
# По умолчанию 100
CNT="100"
 
TMS="$(date +%s)"
STR=""
STX=""
 
let "SEK = MNT * 60"
let "EXP = TMS - SEK"
 
while :
do   
     
    STR="$STR$STX$(date -d @$EXP +'%d/%h/%Y:%H:%M')"
    let "EXP = EXP + 60"
    STX="|"
     
    if [ "$EXP" == "$TMS" ]
    then
        break
    fi
         
done
 
echo "$(cat /var/log/nginx/access.log | grep -E $STR | awk '{print $1}' | sort -n | uniq -c | sort -nr | head -n$CNT)"
