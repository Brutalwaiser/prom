#!/bin/bash
cd /u01/jenkinsgpm/kafka-mon
cat /dev/null > result2.html
echo "<!DOCTYPE html><html>" >> result2.html
FILE=cluster.conf
while read LINE; do
#чтение каждой строки
IFS=';' read -r -a STR <<< "$LINE"
# установить символ-разделитель ";", -a STR - алиас для LINE
echo -e "<h1><p><font size="3" color="black" face="Arial"> Info from kafka cluster :  ${STR[0]} </font></p></h1>" >> result2.html
echo -e "<h2><p><font size="2" color="black" face="Arial"> Consumer ${STR[1]} </font></p></h2>" >> result2.html
echo -e '<meta charset="utf-8"><style>' >> result2.html
echo -e "table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } </style>" >> result2.html
echo '<table><body>' >> result2.html
/u01/jenkinsgpm/kafka/bin/kafka-consumer-groups.sh --bootstrap-server ${STR[0]} --describe --group ${STR[1]} | awk '{if ($5 > 1 && $1 ~ /rawdata/)
 print "<tr><td>"$1"</td><td>"$2"</td><td>"$5"</td></tr>"}' >> result2.html
echo '</table></body>' >> result2.html
echo "<h3><p><font size="3" color="black" face="Arial"> Info from kafka cluster :  ${STR[0]} </font></p></h3>" >> result2.html
echo -e "<h4><p><font size="2" color="black" face="Arial"> Consumer ${STR[2]} </font></p></h4>" >> result2.html
echo '<table><body>' >> result2.html
/u01/jenkinsgpm/kafka/bin/kafka-consumer-groups.sh --bootstrap-server ${STR[0]} --describe --group ${STR[2]} | awk '{if ($5 > 1 && $1 ~ /rawdata/)
 print "<tr><td>"$1"</td><td>"$2"</td><td>"$5"</td></tr>"}' >> result2.html
echo '</table></body>' >> result2.html
done < $FILE
echo '</html>' >> result2.html
cat result2.html | tr -d '\n' > result3.html
sed 's/<table><body><tr><td>rawdata/<table><body><tr><th>TOPIC<\/th><th>PARTITION<\/th><th>LAG<\/th><\/tr><tr><td>rawdata/g' /u01/jenkinsgpm/kafka-mon/result3.html > /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  dv-gpm-col2:9092,dv-gpm-col3:9092,dv-gpm-rcol2:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-dv-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  dv-gpm-col2:9092,dv-gpm-col3:9092,dv-gpm-rcol2:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-dv-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  sib-gpm-col2:9092,sib-gpm-col3:9092,sib-gpm-rcol2:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-sib-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  sib-gpm-col2:9092,sib-gpm-col3:9092,sib-gpm-rcol2:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-sib-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  kvk-gpm-col3:9092,kvk-gpm-rcol2:9092,kvk-gpm-rcol3:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-kvk-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  kvk-gpm-col3:9092,kvk-gpm-rcol2:9092,kvk-gpm-rcol3:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-kvk-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  vlg-gpm-col05:9092,vlg-gpm-rcol02:9092,vlg-gpm-rcol03:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-vlg-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  vlg-gpm-col05:9092,vlg-gpm-rcol02:9092,vlg-gpm-rcol03:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-vlg-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  msk-gpm-col3:9092,msk-gpm-rcol2:9092,msk-gpm-rcol3:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-msk-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  msk-gpm-col3:9092,msk-gpm-rcol2:9092,msk-gpm-rcol3:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-msk-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  nw-gpm-col5:9092,nw-gpm-rcol2:9092,nw-gpm-rcol4:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-nw-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  nw-gpm-col5:9092,nw-gpm-rcol2:9092,nw-gpm-rcol4:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-nw-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  cnt-gpm-col2:9092,cnt-gpm-col3:9092,cnt-gpm-rcol2:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-cnt-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  cnt-gpm-col2:9092,cnt-gpm-col3:9092,cnt-gpm-rcol2:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-cnt-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/PIDOR/g' /u01/jenkinsgpm/kafka-mon/result4.html
#
sed -i 's/<h1><p><font size=3 color=black face=Arial> Info from kafka cluster :  url-gpm-col2:9092,url-gpm-col3:9092,url-gpm-rcol2:9092 <\/font><\/p><\/h1><h2><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-url-msk <\/font><\/p><\/h2><meta charset="utf-8"><style>table { width: 400px; border-collapse: separate; } TD {text-align: center; background: #fff; padding: 5px; border: 1px solid black; } TH {text-align: center; background: maroon; color: white; padding: 5px; border: 1px solid black; } <\/style><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed -i 's/<h3><p><font size=3 color=black face=Arial> Info from kafka cluster :  url-gpm-col2:9092,url-gpm-col3:9092,url-gpm-rcol2:9092 <\/font><\/p><\/h3><h4><p><font size=2 color=black face=Arial> Consumer mirror-maker-gpm-url-nw <\/font><\/p><\/h4><table><body><\/table><\/body>/g' /u01/jenkinsgpm/kafka-mon/result4.html
sed 's/</\n</g' /u01/jenkinsgpm/kafka-mon/result4.html > /u01/jenkinsgpm/kafka-mon/result5.html
(
#  echo To: sergey.chernyakov@megafon.ru
#  echo To: vladimir.fomin@megafon.ru
  echo To: alexander.filatov@megafon.ru
#  echo To: gpm@megafon.ru
  echo "Content-Type: text/html; "
  echo Subject: test1
  echo
  cat result5.html
) | sendmail -t
