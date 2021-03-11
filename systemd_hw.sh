#!/usr/bin/bash

#localectl set-locale LANG=ru_RU.utf8
#localectl set-keymap ruwin_ctrl-UTF-8
timedatectl set-timezone Europe/Minsk   #<------ Устанавливаем "родную" таймзону Минск
file1=/vagrant/hw_part_1/createlog.service
file2=/vagrant/hw_part_1/logwatch.service
file3=/vagrant/hw_part_1/logwatchtime.timer
file4=/vagrant/hw_part_1/logwatch
file5=/vagrant//hw_part_1genstring_h.sh
file6=/vagrant/hw_part_1/teststring.sh
systemdconf=/etc/systemd/system
apache1=/vagrant/hw_part_2/port8082.conf
apache2=/vagrant/hw_part_2/port8083.conf
var_httpd=/vagrant/hw_part_2/httpd@.service
jira_service=/vagrant/hw_part_3/jira.service
yum -y install httpd > /dev/null  
yum -y install java-11-openjdk.x86_64  > /dev/null            #<---- Установка java для запуска jira, с помощью systemd 
setenforce Permissive                                           #<------ Пока  отключаем seLinux
i=0
#ДЗ systemd часть первая - Cоздать сервис и unit-файлы для этого сервиса

echo ""
echo ""
echo -e "\e[31m                                  Домашнее задание часть первая, создать сервис и unit-файлы для этого сервиса. Скрипт мониторинга log файла на наличие ключевого слова \e[0m"
echo ""
echo "Start"



#if [[ -f "$file1" && -f "$file2" && -f "$file3" && -f "$file4" && "$file5" && "$file6" ]]
#    then
#            for i in $file{1..3}
 #               do
#                       cp $i $systemdconf
#                            
#                            if [[ $? -eq 0 ]]
#                                    then
#                                            echo "Copy done"
#                                    else 
#                                            echo "Error copy file "
#                                            
#                            fi
#                       chmod 644 $systemdconf/$(echo $i | cut -f 4 -d /)
#                
#                  done          
#            cp $file4 /etc/sysconfig/
#            systemctl start $(echo $file1 | cut -f 4 -d /) && echo "Запуск генератора ключевого слова выполнен $?"
#            #systemctl start $file3
#            systemctl start  $(echo $file3 | cut -f 4 -d /) && echo "Запуск таймера выполнен $?"
# 
# else 
#            echo " Проверте наличие конфигурационных файлов или скриптов !!!"
#fi


echo ""
echo ""
echo -e "\e[31m                                  Домашнее задание часть вторая, запуск двух экземпляров httpd на разных портах\e[0m"
echo ""
echo "Start"

#if [[ -f "$apache1" && -f "$apache2" && -f "$var_httpd" ]]
        
#        then
 #                
#                cp $apache1  /etc/httpd/conf/
##                cp $apache2  /etc/httpd/conf/
#                cp $var_httpd $systemdconf
#                #Проверяем, не запущены ли экземпляры уже, systemd status httpd@......service
#                systemctl status httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service > /dev/null 2>&1
#                test1=$?
#                systemctl status httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service > /dev/null 2>&1
#                test2=$?
#                #Если запущены экземпляры то перегружаем сервисы
#                if [[ $test1 -eq 0 ]]
#                        then
#                                systemctl daemon-reload
#                                systemctl restart httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service
#                                                        
#                       else
#                                # Если не запущены, то стартуем их
 #                               systemctl start httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service &&  echo "Старт первого экземпляра  httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .) экземпляра #выполнен"
#                fi
#                #Если запущены экземпляры то перегружаем сервисы
#               if [[ $test2 -eq 0 ]]
#                        then
#                                systemctl daemon-reload
#                                systemctl restart httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service
#                        else
#                                # Если не запущены, то стартуем их
#                                systemctl start httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service &&  echo "Старт первого экземпляра  httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .) экземпляра #выполнен"
#                fi
#                
#                 # Выводим результат запуска экземпляров, httpd стартанут на разных портах (8082 и 8083)               
#                ss -ntlp | grep 808*
#                    
#        else 
#                echo " Нет конфигурационных файлов "
#                echo "Запуск задачи невозможен"
#                
#fi                

echo ""
echo ""
echo -e "\e[31m                                  Домашнее задание часть третья, запуск java сервиса jira с нестандартным кодом завершения программы\e[0m"
echo ""
echo "Start"


if [[ ! -d /home/vagrant/download ]]; then  mkdir -p  /home/vagrant/download; fi
if [[ ! -d /opt/jira ]]; then mkdir -p /opt/jira; fi
jira_source=/home/vagrant/download
jira_prog=/opt/jira
cp $jira_service $systemdconf
systemctl daemon-reload

if [[ ! -f $jira_source/atlassian-jira-software-8.13.4.tar.gz ]]
        then 
                curl https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-8.13.4.tar.gz -o $jira_source/atlassian-jira-software-8.13.4.tar.gz 2>&1 > /dev/null
                tar -xzf $jira_source/atlassian-jira-software-8.13.4.tar.gz -C /opt/jira --strip 1
        else
                #rm -rf /opt/jira/*
                tar  -xzf $jira_source/atlassian-jira-software-8.13.4.tar.gz -C /opt/jira --strip 1
              
fi

if [[ -f /opt/jira/bin/start-jira.sh ]]
        then
                systemctl start jira
        else
                echo "для запуска сервиса jira через systemd  не найден стартовый скрипт"

fi
