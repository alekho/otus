#!/bin/bash

# эта переменная нужна для расчета времени ЦПУ
# подсмотрено на просторах интеренета https://stackoverflow.com/questions/16726779/how-do-i-get-the-total-cpu-usage-of-an-application-from-proc-pid-stat
clk_tck=$(getconf CLK_TCK)

# выводим заголовок 
echo "PID|TTY|STAT|TIME|COMMAND" | column -t -s "|";
# пишем нашу функцию
mypsax() {
# в псевдофайловой системе proc мы численное значение pid директорий и сортируем их в порядке возрастания
for pid in $(ls /proc | grep -E "^[0-9]+$" | sort -n); do
# проверяем на существование файл, а затем получаем необходимые нам значенияя.
# значения находим в man proc
        if [ -e /proc/$pid/stat ]; then
                comm=$(cat /proc/$pid/stat | awk -F" " '{print $2}')
                state=$(cat /proc/$pid/stat | awk -F" " '{print $3}')
                tty_nr=$(cat /proc/$pid/stat | awk -F" " '{print $7}')
# и тут нас ждет сюрприз, tty_nr возвращает число, конфертацию в дввоичный формат
# потом в hex - не осилил, но вспомнил что на лекции говорили про дискрипторы которые лежат
# в /proc/$pid/fd, этим и воспользуемся.
# Сравниваем с зиро, если да, то ставим ?, или грепаем дискриптор и выводим значение.
                [[ $tty_nr -eq 0 ]] && tty='?' || tty=$(ls -l /proc/$pid/fd/ | grep -E 'tty|pts' | awk -F"/" '{print $3  $4}' | uniq)
# затык  номер два, решение, повторюсь, найдено в тырнете, добавим только  часы миннутки.                
                utime=$(cat /proc/$pid/stat | awk -F" " '{print $14}')
                stime=$(cat /proc/$pid/stat | awk -F" " '{print $15}')
                total_time=$((utime + stime))
                time=$((total_time / clk_tck))
                in_hour=$((time / 60))
                in_min=$((time - (in_hour * 60)))
                work_time="$in_hour:$in_min"
                echo "${pid}|${tty}|${state}|${work_time}|${comm}"
        fi
done
}
mypsax | column -t -s "|"
