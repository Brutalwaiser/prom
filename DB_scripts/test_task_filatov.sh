#!/bin/bash

##
# bash-скрипт, который при использовании ключей выполняет следующие действия:
# 1. Устанавливает подключение c PostgreSQL (или Oracle DB, на выбор) и вносит произвольный текст в таблицу (вводится аргументами) одной строкой по типу
# ./script.sh -n TABLE_NAME TEXT
# 2. Устанавливает подключение с PostgreSQL (или Oracle DB, на выбор) и выводит дату последнего изменения указанной таблицы (вводится аргументом)
##

DEFAULT_COLUMN=address
TABLE_NAME=$2
COLUMN_VALUE=$3

case "$1" in
  -n|-i)
    ;;
  not_an_item)
    mode=help
    ;;
esac

while getopts ":i:n" option; do
    case "$option" in
    n)
        if [[ -n $2 ]] && [[ -n $3 ]] && [[ -z $4 ]]; then
          mode=new_string
        else
          mode=help
        fi
        ;;
    i)
        if [[ -n $2 ]] && [[ -z $3 ]]; then
          mode=baseinfo
        else
          mode=help
        fi
        ;;
    *)
      mode=help
        ;;

    esac
done

if [ $OPTIND -eq 1 ]; then
mode=help;
fi

case "$mode" in
baseinfo)
    psql -c "SELECT pg_xact_commit_timestamp(xmin), * FROM  ${TABLE_NAME}" | tail -n3 
    # tail нужен, так как вывод timestamp в postgreSQL выводит всю таблицу целиком. 
    #-n3 - потому что последняя строка вывода пустая, а предпоследняя - показывает количество строк в таблице.
    #а, и еще - в postgreSQL по дефолту таймкоды не ставятся. Их надо включать в конфиге.
    ;;
esac


case "$mode" in
new_string)
    psql -c "insert into ${TABLE_NAME} (${DEFAULT_COLUMN}) values ('${COLUMN_VALUE}')"
    ;;
esac

case "$mode" in
help)
    echo "Invalid request."
    echo "to check the last modification time in the DB, type -i and 'table name' arg"
    echo "to enter new data into the database, type -n , 'table name' and 'new value' args"
    ;;
esac
