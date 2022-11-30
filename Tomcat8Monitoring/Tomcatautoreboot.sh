#!/bin/bash
link="https://api.gpm01.megafon.ru/percent"
link_2="https://api.gpm01.megafon.ru/monitoring"
httpcd=$(curl -I -s $link -o /dev/null -w "%{http_code}\n")
httpcd_2=$(curl -I -s $link_2 -o /dev/null -w "%{http_code}\n")
#костыль
TmctErrTrap=$(curl -I -s $link -o /dev/null -w "%{http_code}\n")
timestamp=$(date "+%Y.%m.%d-%H:%M:%S")
if
  [ $httpcd != 200 ];
        then
            echo "Tomcat не получает данные от БД ядра GPM" | mail -s "Tomcat alert" -S smtp="mail.megafon.ru:25" gpm@megafon.ru;
                elif
                    [ $httpcd_2 != 200 ];
                then
                    sudo systemctl restart tomcat8
                    echo "tomcat restarted at $timestamp" >> /data/jenkinsgpm/scripts/tmct8_logs/TmctMonitor.log
        else
            echo "tomcat is alive $timestamp" >> /data/jenkinsgpm/scripts/tmct8_logs/TmctMonitor.log
fi
sleep 120
if
  [ $TmctErrTrap != 200 ];
        then
            sudo systemctl restart tomcat8
               echo "Повторный код ошибки. Tomcat был перезапущен." | mail -s "Tomcat alert" -S smtp="mail.megafon.ru:25" gpm@megafon.ru;
               echo "(2-nd trigger) tomcat restarted at $timestamp" >> /data/jenkinsgpm/scripts/tmct8_logs/TmctMonitor.log
        else
               echo "tomcat is still alive $timestamp" >> /data/jenkinsgpm/scripts/tmct8_logs/TmctMonitor.log
fi
