/data/Middleware/oas590/user_projects/domains/bi/bitools/bin/importarchive.sh ssi /tmp/obires.bar/*/ssi.bar encryptionpassword=****** >> /home/oracle/scripts/OBIErescp.log
##echo "Well done!"
##echo "Hello" | mail -s "Hello, i am automatic DB-updater" -S smtp="mail.megafon.ru:25" alexander.filatov@megafon.ru;##
echo "Backup метаданных и отчетов OAS с msk-fpm-bi на msk-fpm-bi02 выполнен успешно." | mail -s "OBIEE backup notification" -S smtp="mail.megafon.ru:25" pm@megafon.ru;
echo "Notification of the end of the operation was sent to the mail of PM-group."
