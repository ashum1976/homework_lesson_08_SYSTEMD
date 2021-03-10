#!/usr/bin/bash

sleep 5
aaa=0
testlogfile=/var/log/test
while [[ $aaa -lt 10 ]]
    do
        
        #/usr/bin/logger "security alerts"
        echo "security alert $aaa" > $testlogfile 
        echo "test string" >> $testlogfile
        sleep 10
        (( aaa++ ))
done
