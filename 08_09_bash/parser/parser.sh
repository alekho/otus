#!/bin/bash


#####################################
## ПЕРЕМЕННЫЕ
#####################################

# Рабочая директория
workdir=/home/vagrant/parser
# Отметка времени в формат nginx
timestamp=$(date +%Y/%B/%m" "%T%t%Z)
# Файл исходного лога
log=$workdir/access.log
# Файл временного лога
templog=$workdir/log.tmp
# Файл блокировки 
locked=$workdir/lockedfile
# Номер последней строки
lln=$(cat $log | awk 'END { print NR }')
# Временный место хранения переменных
tempvars=$workdir/vars.tmp
# Содержание сообщения
message=$workdir/message



# Функция очистки, подчищает временные файлы, при корректном коде возврата
clean() {
  exitcode=$? 
  find $message 2>/dev/null && rm -f $message
  find $templog 2>/dev/null && rm -f $templog
  find $locked 2>/dev/null && rm -f $locked
  exit $exitcode
}

# Функция задания первоначальных перменных, или из файла
setvars () {
  if [  ! -f $tempvars ]
  then
    mkdir -p ${tempvars%/*}
    touch $tempvars
    chmod +777  $tempvars
    startline=1
    lastcheck="-"
  else
    i=0 
    while IFS='' read -r line; do 
      array[$i]=$(echo ${line} | awk -F"=" '{print $2}') 
      ((i++))
    done < "$tempvars"
    startline=${array[0]}
    lastcheck=${array[1]}
  fi
}

setvars

range=$((lln - startline + 1))
head -n $lln $log |tail -n $range  > $templog

# Формируем сообщение
# Обрабатываемый диапозон времени лога
starttime=$(cat $templog|head -n 1 |awk -F" " '{print $4}'|sed "s/\[//")
stoptime=$(cat $templog|tail -n 1 |awk -F" " '{print $4}'|sed "s/\[//")
# Само сообщение
message=$(
echo "#####################  НАЧАЛО  ####################" 
echo "#  Начальное время " $starttime
echo "###################################################" 
echo "#  Конечное время "  $stoptime 
echo "###################################################" 
echo "#  5 IP адресов с максимальным количеством запросов"
cat $templog |awk '{print $1}' |sort |uniq -c |sort -rn| head -n 5
echo "###################################################" 
echo "#  5 самых частых запросов"
cat $templog |awk '{print $7}' |sort |uniq -c |sort -rn| head -n 5 
echo "###################################################"
echo "#   Все ошибки " 
cat $templog |awk '{print $9}' |egrep "^4|^5"|sort |uniq -c |sort -rn 
echo "###################################################"
echo "#   Все статусы запросов " 
cat $templog |awk '{print $9}' |sort |uniq -c |sort -rn 
echo "#####################  КОНЕЦ!  ####################" 
)

# Проверяем есть ли файл блокировки(защита от повторного запуска)
if [[ -f $locked ]]; then
  echo "ужо работает, отбой" >&2
  exit 1
fi

touch $locked 

# Отправляем письмо
echo "$message" | mailx  -s "АЛЯЯЯЯРМА!!!" otus 

endline=$(($lln+1)) 

# Сохраняем посденее состояние скрипта, для последующего выполнения с этого же места
startline=$endline
echo "$startline" > $tempvars
lastcheck=$timestamp >> $tempvars
echo "$lastcheck" >> $tempvars 

# Ловушка, для запуска функции очистки
trap "clean" INT TERM EXIT

exit 0