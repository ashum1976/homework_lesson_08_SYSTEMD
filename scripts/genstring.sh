#!  /usr/bin/bash

string=0

for (( i=0; i<100; ++i ))
            do
            string=$(( ${string} + (( ${i} + 3 ))))
            head -n $string ./web_access.log >> test.txt
            echo $string
            echo -n " $(date) security alert" >> test.txt
            sleep 10
done

printf "Тест закончен !!!! \n"

cat /dev/null > ./test.txt

for line in `cat lines.txt`
do
  sed -n "${line}p" text.txt
done
