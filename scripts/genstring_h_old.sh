#!/usr/bin/bash

string=0
maxcount=10
range=500

for (( i=0; i<3; ++i ))
      do
  
         while [[ $string -lt $maxcount ]]
                 do
                       
                       # Присваиваем рандомные целые числа переменной numberline
                       numberline=$RANDOM 
                       # Выбрать числа, в диапазоне 0-500, остаток от деления $RANDOM (стандартная функция для генерации рандомных целых чисел в диапазоне 0-32768), на 500
                       (( numberline %= $range ))
                       #Рандомное число может быть "0", исключаем это, +1
                       (( numberline += 1 ))
                       # Напечатать рандомные номера строк и перенаправить вывод в файл test.txt
                       sed -n "${numberline}p" /installs/Study/OTUS/lesson_08_SYSTEMD/homework_lesson08_SYSTEMD/scripts/web_access.log >> /home/andrey/111/test.txt
                       (( string++ ))
         done
            
            string=0
            echo "$(date) security alert" >> /home/andrey/111/test.txt
            sleep 20
            
done

printf "Тест закончен !!!! \n"
sleep 60
cat /dev/null > /home/andrey/111/test.txt
printf "Тестовый файл защищен !!!! \n"


