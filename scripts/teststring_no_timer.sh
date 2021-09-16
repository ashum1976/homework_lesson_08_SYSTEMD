#!/usr/bin/bash

if [[ -n "$1" && -n "$2" ]]
    then
    
        tail -fn0 $1 | while read alert
            do
                echo ${alert} |  grep -i $2  
                    if [[ $? -eq 0 ]]
                        then
                        
                            echo "security alert" | write andrey
                            #echo "$(date) security alert" > /installs/alert.txt
                    fi       
            done
                    
    else
        echo "Не заданы путь и ключевая фраза для поиска в конфиг файле"
fi
