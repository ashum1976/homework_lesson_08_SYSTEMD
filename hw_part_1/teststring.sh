#!/usr/bin/bash

if [[ -n "$1" && -n "$2" ]]
    then    
          tail -n2 $1 | grep -i $2
          if [[ $? -eq 0 ]]
                        then
                        
                            echo "security alert" | write vagrant
                            
                    fi       
    
    else
        echo "Не заданы путь или ключевая фраза для поиска в конфиг файле"
        
fi
