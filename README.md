
###                                           1.Система инициализации Systemd







В системах работающих под управлением systemd, /sbin/init ---> символическая ссылка /sbin/init -> ../lib/systemd/systemd












###                                          2. ДЗ homework_lesson_08_SYSTEMD

<details>

  <summary> Скрипт для запуска ДЗ </summary>

        #!/usr/bin/bash

        timedatectl set-timezone Europe/Minsk                       #<------ Устанавливаем "родную" таймзону Минск
        file1=/vagrant/hw_part_1/createlog.service
        file2=/vagrant/hw_part_1/logwatch.service
        file3=/vagrant/hw_part_1/logwatchtime.timer
        file4=/vagrant/hw_part_1/logwatch
        file5=/vagrant/hw_part_1/genstring_h.sh
        file6=/vagrant/hw_part_1/teststring.sh
        systemdconf=/etc/systemd/system                             #<---- Каталог где хранятся файлы сервисов, таймеров
        apache1=/vagrant/hw_part_2/port8082.conf
        apache2=/vagrant/hw_part_2/port8083.conf
        var_httpd=/vagrant/hw_part_2/httpd@.service
        jira_service=/vagrant/hw_part_3/jira.service
        yum -y install httpd > /dev/null  
        yum -y install java-11-openjdk.x86_64  > /dev/null          #<---- Установка java для запуска jira, с помощью systemd
        setenforce Permissive                                       #<---- Пока  отключаем seLinux
        i=0
        #ДЗ systemd часть первая - Cоздать сервис и unit-файлы для этого сервиса

        echo ""
        echo ""
        echo -e "\e[31m                                  Домашнее задание часть первая, создать сервис и unit-файлы для этого сервиса. Скрипт мониторинга log файла на наличие ключевого слова \e[0m"
        echo ""
        echo "Start"



        if [[ -f "$file1" && -f "$file2" && -f "$file3" && -f "$file4" && "$file5" && "$file6" ]]
            then
                    for i in $file{1..3}
                       do
                               cp $i $systemdconf

                                    if [[ $? -eq 0 ]]
                                            then
                                                    echo "Copy done"
                                            else
                                                    echo "Error copy file "

                                    fi
                               chmod 644 $systemdconf/$(echo $i | cut -f 4 -d /)

                          done          
                    cp $file4 /etc/sysconfig/
                    systemctl start $(echo $file1 | cut -f 4 -d /) && echo "Запуск генератора ключевого слова выполнен $?"
                    #systemctl start $file3
                    systemctl start  $(echo $file3 | cut -f 4 -d /) && echo "Запуск таймера выполнен $?"

         else
                    echo " Проверте наличие конфигурационных файлов или скриптов !!!"
        fi


        echo ""
        echo ""
        echo -e "\e[31m                                  Домашнее задание часть вторая, запуск двух экземпляров httpd на разных портах\e[0m"
        echo ""
        echo "Start"

        if [[ -f "$apache1" && -f "$apache2" && -f "$var_httpd" ]]

                then

                        cp $apache1  /etc/httpd/conf/
                        cp $apache2  /etc/httpd/conf/
                        cp $var_httpd $systemdconf
                        #Проверяем, не запущены ли экземпляры уже, systemd status httpd@......service
                        systemctl status httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service > /dev/null 2>&1
                        test1=$?
                        systemctl status httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service > /dev/null 2>&1
                        test2=$?
                        #Если запущены экземпляры то перегружаем сервисы
                        if [[ $test1 -eq 0 ]]
                                then
                                        systemctl daemon-reload
                                        systemctl restart httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service

                               else
                                        # Если не запущены, то стартуем их
                                       systemctl start httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .).service &&  echo "Старт первого экземпляра  httpd@$(echo $apache1 | cut -f 4 -d / | cut -f 1 -d .) экземпляра #выполнен"
                        fi
                        #Если запущены экземпляры то перегружаем сервисы
                       if [[ $test2 -eq 0 ]]
                                then
                                        systemctl daemon-reload
                                        systemctl restart httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service
                                else
                                        # Если не запущены, то стартуем их
                                        systemctl start httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .).service &&  echo "Старт первого экземпляра  httpd@$(echo $apache2 | cut -f 4 -d / | cut -f 1 -d .) экземпляра #выполнен"
                        fi

                         # Выводим результат запуска экземпляров, httpd стартанут на разных портах (8082 и 8083)               
                        ss -ntlp | grep 808*

                else
                        echo " Нет конфигурационных файлов "
                        echo "Запуск задачи невозможен"

        fi                

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
                        tar -xvzf $jira_source/atlassian-jira-software-8.13.4.tar.gz -C /opt/jira --strip 1
                else
                        #rm -rf /opt/jira/*
                        tar  -xvzf $jira_source/atlassian-jira-software-8.13.4.tar.gz -C /opt/jira --strip 1

        fi

        if [[ -f /opt/jira/bin/start-jira.sh ]]
                then
                        systemctl start jira
                else
                        echo "для запуска сервиса jira через systemd  не найден стартовый скрипт"

        fi



</details>

####                            2.1 ДЗ часть 1. Сервис отслеживающий лог файл


#### Генерируем ключевое слово, 40 строчек, с задержкой 10 сек.

**Сервис генерации лог файла, который вызывает скрипт генерации посредством systemd:**

<details>

  <summary> Сервис генерации лог файла </summary>

            [Unit]
            Description=Create log file test.txt

            [Service]
            Type=simple
            ExecStart=/vagrant/hw_part_1/genstring_h.sh
            StartLimitInterval=0

            [Install]
            WantedBy=multi-user.target

</details>

<details>

  <summary> Скрипт генерации ключевого слова </summary>


            #!/usr/bin/bash

            sleep 5
            aaa=0
            testlogfile=/var/log/test
            while [[ $aaa -lt 20 ]]
                do

                    #/usr/bin/logger "security alerts"
                    echo "security alert $aaa" > $testlogfile
                    echo "test string" >> $testlogfile
                    sleep 10
                    (( aaa++ ))
            done
</details>



#### Проверка лог файла  

Проверяем лог файл (/var/log/test), созданный предыдущим скриптом, на наличие ключевого слова. Проверка выполняется путём запуска .timer сервиса, по расписанию каждые 30 сек.

**Таймер активации сервиса проверки:**

<details>
    <summary> Таймер активации проверки </summary>

            [Unit]
            Description=Timer for service logwatch

            [Timer]
            Unit=logwatch.service
            OnCalendar=*-*-* *:*:00,30
            AccuracySec=1s

            [Install]
            WantedBy=timers.target

</details>

**Сервис проверки лог файла:**

<details>
    <summary> Сервис проверки лог файла </summary>

            Unit]
            Description=Log watch, created by script genstring_h.sh
            Requires=createlog.service
            #BindsTo=createlog.service
            #Before=createlog.service

            [Service]
            Type=simple
            EnvironmentFile=/etc/sysconfig/logwatch                     <----- ключевое слово и путь к log-файлу, берутся из этого файла
            ExecStart=/vagrant/hw_part_1/teststring.sh ${log_path} ${alert_word}
</details>


**Скрипт проверки ключевого слова в лог файле:**

 <details>
            <summary> Скрипт проверки ключевого слова в лог файле </summary>           

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
</details>



####                            2.2 ДЗ часть 2. Экземпляры сервиса httpd



На базе существующего шаблона httpd@.service, создаём два конфиг файла, для запуска двух экземпляров httpd сервиса на двух портах 8082 и 8083

**Шаблон httpd@.service:**


            # This is a template for httpd instances.
            # See httpd@.service(8) for more information.

            [Unit]
            Description=The Apache HTTP Server
            After=network.target remote-fs.target nss-lookup.target

            [Service]
            Type=notify
            Environment=LANG=C
            Environment=HTTPD_INSTANCE=%i
            ExecStartPre=/bin/mkdir -m 710 -p /run/httpd/instance-%i
            ExecStartPre=/bin/chown root.apache /run/httpd/instance-%i
            ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND -f conf/%i.conf
            ExecReload=/usr/sbin/httpd $OPTIONS -k graceful -f conf/%i.conf
            # Send SIGWINCH for graceful stop
            KillSignal=SIGWINCH
            KillMode=mixed
            PrivateTmp=true

            [Install]
            WantedBy=multi-user.target

**Конфигурация экземпляра для запуска на порту 8082:**

<details>
    <summary> Сервис проверки лог файла </summary>

            DefaultRuntimeDir /run/httpd/instance-${HTTPD_INSTANCE}
            PidFile /run/httpd/instance-${HTTPD_INSTANCE}.pid

            Listen 127.0.0.1:8082

            Include conf.modules.d/*.conf

            User apache
            Group apache


            ServerAdmin root@localhost


            <Directory />
                AllowOverride none
                Require all denied
            </Directory>


            DocumentRoot "/var/www/html"

            <Directory "/var/www">
                AllowOverride None
                Require all granted
            </Directory>

            <Directory "/var/www/html">
                Options Indexes FollowSymLinks

                AllowOverride None

                Require all granted
            </Directory>

            <IfModule dir_module>
                DirectoryIndex index.html
            </IfModule>

            <Files ".ht*">
                Require all denied
            </Files>

            ErrorLog "logs/${HTTPD_INSTANCE}_error_log"

            LogLevel warn

            <IfModule log_config_module>
                LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
                LogFormat "%h %l %u %t \"%r\" %>s %b" common

                <IfModule logio_module>
                LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
                </IfModule>


                CustomLog "logs/${HTTPD_INSTANCE}_access_log" combined
            </IfModule>

            <IfModule alias_module>


                ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"

            </IfModule>

            <Directory "/var/www/cgi-bin">
                AllowOverride None
                Options None
                Require all granted
            </Directory>

            <IfModule mime_module>
                TypesConfig /etc/mime.types

                AddType application/x-compress .Z
                AddType application/x-gzip .gz .tgz



                AddType text/html .shtml
                AddOutputFilter INCLUDES .shtml
            </IfModule>

            AddDefaultCharset UTF-8

            <IfModule mime_magic_module>
                MIMEMagicFile conf/magic
            </IfModule>


            EnableSendfile on

</details>




####                            2.3 Д3 часть 3.  Сервис jira

**Конфигураци юнита, для запуска jira сервиса посредством systemd:**

<details>

  <summary> Конфигурация systemd юнита jira.service </summary>

                [Unit]
                Description=Jira Server
                After=network.target

                [Service]
                Type=forking
                User=vagrant
                Group=vagrant
                Environment="JRE_HOME=/etc/alternatives/jre"
                ExecStart=/opt/jira/bin/start-jira.sh
                #ExecStop=/opt/jira/bin/stop-jira.sh
                SuccessExitStatus=143
                RestartPreventExitStatus=143
                Restart=on-failure

                ## Ограничения процесса по нескольким параметрам cgroup
                #Ограничение виртуальной памяти
                #LimitAS=20M
                #Ограничение по макимальному числу пользовательских процессов
                LimitNPROC=100
                #Ограничение по количеству файловых дискрипторов ( количеству файлов)
                LimitNOFILE=350
                #Ограничение по времени использования CPU
                LimitCPU=3

                [Install]
                WantedBy=multi-user.target

</details>

SuccessExitStatus=143         *<---- Указываем systemd, что код выхода 143 правильный*

RestartPreventExitStatus=143  *<---- Предотвращаем перезапуск сервиса при появлении такого кода выхода, который возникает при остановке jira сервиса*

Restart=on-failure            *<---- При возникновении ошибки, в виде неверного кода выхода ( для нормальных приложение он = 0, но не для java, где он равен 128+15(SIGTERM) = 143), перезапустить наше приложение*


ss -t4unpl - запущенные сервисы на портах

lsof -nP -i4 | grep httpd | grep LISTEN - отбор по запущенному сервису httpd, порты в статусе LISTEN, IPv4 (для включения IPv6 - i6 или без ключа -i тогда оба протокола)

**curl https://product-downloads.atlassian.com/software/jira/downloads/atlassian-jira-software-7.11.2.tar.gz -o /home/vagrant/atlassian-jira-software-8.13.4.tar.gz**




###                                          3. Просмотр, управление, команды юнитов systemd

#### <span style="color:blue"> Полезные инструменты, которые предоставляет systemd.</span>

  <span style="color:blue"> _localectl_</span> - **централизованное управление языковыми и региональными параметрами.**

    Вывод команды **"localectl":**  

      System Locale — текущая системная локаль, т. е. набор правил, определяющих язык системы, формат денежных единиц, часовой пояс и т. д.
      VC Keymap — раскладка клавиатуры для консоли.
      X11 Layout — раскладки клавиатуры, используемые в графической системе.
      X11 Model — тип/модель клавиатуры
      X11 Variant — варианты раскладки клавиатуры, используемые в графической системе. Примеры: русская машинописная, DVORAK, QUERTY и т. д.
      X11 Options — опции, в том числе горячие клавиши для переключения раскладки и отображение текущего состояния с помощью индикатора Scroll Lock.

  <span style="color:blue">_timedatectl_</span> - **управление настройками времени и даты**

    Вывод команды **"timedatectl":**  

      Local time — местное время.  
      Universal time — UTC или всемирное координированное время. Отправная точка для отсчета часовых поясов.  
      RTC time — время в аппаратных часах ПК или сервера.  
      Time Zone — часовой пояс.  
      Network time on — показывает, включен ли ntp-клиент, входящий в состав systemd. Даже если он отключен, синхронизация может выполняться сторонними клиентами.  
      NTP synchronized — показывает, синхронизировано ли время с ntp-сервером.  
      RTC in local TZ — показывает, какое время хранится в аппаратных часах: локальное или всемирное. Таким образом, yes означает локальное время, no — всемирное.  

<span style="color:blue"> _loginctl_</span> - **Просмотр и упрвление сессиями пользователей**



####   3.1 Управление юнитами

1.  
    systemctl cat sshd   <----- просмотр содержимого файла   выбранного юнита  ( systemd )                      

2.
    systemctl daemon-reexec   <----   перечитать конфиг файл /etc/systemd/system.conf, при изменении конфигурации.

3.
    systemctl daemon-reload   <---- при изменении параметров запуска юнита, перечитать все юниты.

4.  


#####   3.1.1 Просмотр  юнитов ( systemctl --list-*****)

        1.    systemctl list-timers   <------- Список загруженных таймеров ( расписание как в кроне)
        2.    systemctl list-dependencies  <------ Рекурсивно отображает требуемые юниты
        3.    systemctl list-jobs                     <------  Список работ (jobs)
        4.    systemctl list-machines              <------ Список локальных хостов или контейнеров
        5.    systemctl list-sockets                   <------ Список текущих загруженных сокет юнитов
        6.    systemctl list-unit-files                    <------ Список инсталлированных файлов юнитов
        7.    systemctl list-units                              <------ Список текущих загруженных юнитов

#####   3.1.2 **systemd-delta**          <------ Команда отображает что по юнитам расширено, перенаправлено, замаскировано

        [REDIRECTED] /etc/systemd/system/dbus-org.freedesktop.timedate1.service → /usr/lib/systemd/system/dbus-org.freedesktop.timedate1.service

        [EQUIVALENT] /etc/systemd/system/default.target → /usr/lib/systemd/system/default.target

        [MASKED]     /etc/systemd/system/systemd-timedated.service → /usr/lib/systemd/system/systemd-timedated.service

        [EXTENDED]   /usr/lib/systemd/system/systemd-udev-trigger.service → /usr/lib/systemd/system/systemd-udev-trigger.service.d/systemd-udev-trigger-no-reload.conf

        [OVERRIDDEN] /etc/modprobe.d/nvidia-installer-disable-nouveau.conf → /usr/lib/modprobe.d/nvidia-installer-disable-nouveau.conf
        Файлы /usr/lib/modprobe.d/nvidia-installer-disable-nouveau.conf и /etc/modprobe.d/nvidia-installer-disable-nouveau.conf идентичны    

___        

####   3.2 Мониторинг        

        **systemctl is-active <unit name>**                         <----- Проверка запущен ли юнит
        **systemctl is-enabled <unit name>**                    <----- Включен ли юнит для автозагрузки
        **systemctl is-failed <unit name>**                 <----- Ошибка  юнита
        **systemctl is-system-running**                 <----- Состояние запущеной ситемы systemd (ranning or degraded)
        **systemctl reset-failed**                  <----- Сброс состояния ошибки

2.  **journalctl -u <unit name>**   <---- Просмотр журнала по выбранному юниту

3.  **journalctl -p 3 -b**  <---- Приведённая команда покажет все сообщения об ошибках, имевших место в системе.

	где "-p" фильтрация по уровню ошибки

		уровни ошибок:

			0 — EMERG (система неработоспособна);
			1 — ALERT (требуется немедленное вмешательство);
			2 — CRIT (критическое состояние);
			3 — ERR (ошибка);
			4 — WARNING (предупреждение);
			5 — NOTICE (всё нормально, но следует обратить внимание);
			6 — INFO (информационное сообщение);
			7 —DEBUG (отложенная печать).
___

####   3.3 Файлы конфигурации

1.
    **/etc/systemd/system.conf**   <------ параметры конфигурации systemd

            Для отображения в выводе команды  systemd-cgtop учёта ресурсов включить параметры:

            DefaultCPUAccounting=yes
            DefaultIOAccounting=yes
            DefaultIPAccounting=yes
            DefaultBlockIOAccounting=yes

2.
    **/etc/systemd/system**  <---- В этом каталоге хранятся все юнит файлы которые создаются вручную. **имеет наивысший приоритет перед остальными директориями**

3.  **/etc/systemd/system/*.wants**    <---- в каталога .wants симлинки при включении сервиса командой systemctl enable

    ls -la  /etc/systemd/system/multi-user.target.wants/sshd.service

    _/etc/systemd/system/multi-user.target.wants/sshd.service -> /usr/lib/systemd/system/sshd.service_

4.  **/etc/sysconfig/**  <---- Директория где хранятся переменные, используемые в юнит-файлах

5.  **systemctl cat sshd**   <---- Просмотреть содержимое юнит-файла

    _[Unit]_
    _Description=OpenSSH server daemon_
    _Documentation=man:sshd(8) man:sshd_config(5)_
    _After=network.target sshd-keygen.target_
    _Wants=sshd-keygen.target_

    _[Service]_
    _Type=notify_
    _EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config_        
    _EnvironmentFile=-/etc/sysconfig/sshd__                             <---- Переменные для service sshd

6.   **systemctl edit --full <name service>**  <--- Будет создан сервис в папке /etc/systemd/service/< _name service_ > Модификация юнита, на базе существующего. Будет использоваться вновь созданный юнит

7.  **systemctl edit <name service>**  <----- Создание дополнительных парамтров или конфигурации для <name service> . Drop-in  расширение конфига юнита.  

        /etc/systemd/system/sshd.service.d/override.conf  <----- создаётся файл с параметрами, дополнительно используемыми в юните. Остальные параметры берутся из настроек "по умолчанию"

___

####   3.4 Man systemd

1.  
    **man systemd.index**       <------ полный man по всем параметрам и значениям Systemd
2.
    **man systemd-system.conf**  <----- man по параметрам конфигурационного файла /etc/systemd/system.conf
3.  
    **man systemd.unit**               <----- man по типам юнитов
4.
    **man systemd.exec**  <---- man ограничения в systemd.
5.  
    **man systemd.resource-control**  <---- man Лимиты systemd
6.  
    **man systemd.exec**  <---- man ограничения в systemd.
7.  
    **man systemd.resource-control**  <---- man Лимиты systemd

___


####   3.5 Анализ работы, состояния, загрузки в systemd

1.  **ps -axf**  <------- просмотр дерева процессов

2.  **systemctl status**   <------- состояние системы, дерево юнитов systemd -----

  <details>

  <summary>Вывод команды  systemctl status</summary>

            nix64amd.bgim.local
            State: running
            Jobs: 0 queued
            Failed: 0 units
            Since: Tue 2021-03-09 07:48:54 +03; 1 day 2h ago
            CGroup: /
            ├─user.slice
            │ ├─user-42.slice
            │ │ ├─session-c1.scope
            │ │ │ ├─2913 gdm-session-worker [pam/gdm-launch-environment]
            │ │ │ ├─3004 /usr/libexec/gdm-x-session --register-session gnome-session --autostart /usr/share/gdm/greeter/autostart
            │ │ │ ├─3014 /usr/libexec/Xorg vt1 -displayfd 3 -auth /run/user/42/gdm/Xauthority -background none -noreset -keeptty -novtswitch -verbose 3
            │ │ │ ├─3187 /usr/libexec/gnome-session-binary --autostart /usr/share/gdm/greeter/autostart
            │ │ │ ├─3207 /usr/bin/gnome-shell
            │ │ │ ├─3220 ibus-daemon --xim --panel disable
            │ │ │ ├─3223 /usr/libexec/ibus-dconf
            │ │ │ ├─3227 /usr/libexec/ibus-x11 --kill-daemon
            │ │ │ ├─3277 /usr/libexec/gsd-xsettings
            │ │ │ ├─3288 /usr/libexec/gsd-a11y-settings
            │ │ │ ├─3297 /usr/libexec/gsd-clipboard
            │ │ │ ├─3299 /usr/libexec/gsd-color
            │ │ │ ├─3300 /usr/libexec/gsd-datetime
            │ │ │ ├─3305 /usr/libexec/gsd-housekeeping
            │ │ │ ├─3307 /usr/libexec/gsd-keyboard
            │ │ │ ├─3313 /usr/libexec/gsd-media-keys
            │ │ │ ├─3319 /usr/libexec/gsd-mouse
            │ │ │ ├─3325 /usr/libexec/gsd-power
            │ │ │ ├─3330 /usr/libexec/gsd-print-notifications
            │ │ │ ├─3331 /usr/libexec/gsd-rfkill
            │ │ │ ├─3333 /usr/libexec/gsd-screensaver-proxy
            │ │ │ ├─3339 /usr/libexec/gsd-sharing
            │ │ │ ├─3346 /usr/libexec/gsd-smartcard
            │ │ │ ├─3351 /usr/libexec/gsd-sound
            │ │ │ ├─3354 /usr/libexec/gsd-wacom
            │ │ │ └─3407 /usr/libexec/ibus-engine-simple
            │ │ └─user@42.service
            │ │   ├─xdg-permission-store.service
            │ │   │ └─3238 /usr/libexec/xdg-permission-store
            │ │   ├─pulseaudio.service
            │ │   │ └─2990 /usr/bin/pulseaudio --daemonize=no
            │ │   ├─init.scope
            │ │   │ ├─2921 /usr/lib/systemd/systemd --user
            │ │   │ └─2924 (sd-pam)
             ............
 </details>            

3.  **systemctl --failed** <---- просмотр юнитов, запуск которых завершился с ошибкой
    **sudo systemctl list-machines**  <---- Информация о хосте, статус юнитов, количество jobs

            [andrey@SrvHomeAMD homework_lesson08_SYSTEMD]$ sudo systemctl list-machines
            NAME                            STATE         FAILED JOBS
            ● SrvHomeAMD.localdomain (host) degraded      1      0

            1 machines listed.

<details>

  <summary>Вывод команды systemctl --failed </summary>

        UNIT           LOAD   ACTIVE SUB    DESCRIPTION
        ● kdump.service  loaded failed failed Crash recovery kernel arming
        ● mcelog.service loaded failed failed Machine Check Exception Logging Daemon

        LOAD   = Reflects whether the unit definition was properly loaded.
        ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
        SUB    = The low-level unit activation state, values depend on unit type.

        2 loaded units listed. Pass --all to see loaded but inactive units, too.
        To show all installed unit files use 'systemctl list-unit-files'        
</details>

4.  **systemctl show sshd** <------ просмотр полной конфигурации параметров преданных сервису и сгенерированных sustemd для этого сервиса

<details>

  <summary>Вывод команды  systemctl show sshd </summary>

        Type=notify
        Restart=on-failure
        NotifyAccess=main
        RestartUSec=42s
        TimeoutStartUSec=1min 30s
        TimeoutStopUSec=1min 30s
        RuntimeMaxUSec=infinity
        WatchdogUSec=0
        WatchdogTimestamp=Tue 2021-03-02 08:06:09 +03
        WatchdogTimestampMonotonic=53329782
        PermissionsStartOnly=no
        RootDirectoryStartOnly=no
        RemainAfterExit=no
        GuessMainPID=yes
        MainPID=2456
        UID=[not set]
        GID=[not set]
        NRestarts=0
        ..............
        ..............
        ..............
        ..............
 </details>


5.  **systemd-cgls**    <------- состояние системы, дерево юнитов systemd

6.  **systemd-analyze**_<------ анализ времени загрузки [ time]_

        Startup finished in 1.289s (kernel) + 27.636s (initrd) + 46.935s (userspace) = 1min 15.862s
        graphical.target reached after 46.924s in userspace

7.  **systemd-analyze critical-chain**   _<------- анализ, что грузилось с наибольшей задержкой_


<details>

  <summary>Вывод команды  systemd-analyze critical-chain</summary>

        The time after the unit is active or started is printed after the "@" character.
        The time the unit takes to start is printed after the "+" character.

        graphical.target @46.924s
        └─multi-user.target @46.924s
          └─plymouth-quit-wait.service @28.835s +18.087s
            └─systemd-user-sessions.service @28.742s +58ms
              └─remote-fs.target @28.740s
                └─remote-fs-pre.target @28.740s
                  └─nfs-client.target @24.494s
                      └─gssproxy.service @24.202s +291ms
                         └─network.target @24.131s
                           └─wpa_supplicant.service @44.865s +93ms
                             └─dbus.service @15.542s
                                └─basic.target @15.526s
                                   └─sockets.target @15.526s
</details>           

8.  **systemd-analyze blame**


<details>

  <summary>Вывод команды  systemd-analyze blame</summary>

        21.405s dracut-initqueue.service
        19.365s systemd-cryptsetup@luks\x2daae6ec35\x2d0b1b\x2d48cb\x2dbfee\x2d5ef2c680c24e.service
        18.087s plymouth-quit-wait.service
        17.399s systemd-cryptsetup@luks\x2d11d3998e\x2d534f\x2d4191\x2d8f34\x2d95d917ae2f35.service
        10.457s dnf-makecache.service
        8.004s udisks2.service
        6.484s systemd-cryptsetup@luks\x2d460961c9\x2d95ca\x2d4ad9\x2dbeea\x2d564b275a47c5.service
</details>

9.  **systemctl list-dependencies**  <------- дерево юнитов условие запуска которых выполняется (зелёный цвет), для тех у кого не выполняется (красный).

10. **systemd-cgtop**          <----- Аналог top с более простым вариантом отображения используемых ресурсов
            **systemd-cgtop --depth**  <--- Глубина отображения вложений от корня cgroups

    Групировка объектов в systemd

    **slice  - объект, представляющий иерархию (сервиса / сессии)**

    _ls -l /sys/fs/cgroup/systemd/*.slice     < -------  slice в systemd находятся в этой директории_

    **scope - объект в slice, группирующий процессы**

    _ls -l /sys/fs/cgroup/systemd/user.slice/user-1000.slice/    <---- scope внутри slice ( на примере пользовательского, user id 1000)_

        итого 0
        .................
        .................
        drwxr-xr-x  2 root   root   0 мар  2 08:06 session-2.scope    <---- scope
        drwxr-xr-x  2 root   root   0 мар  2 08:07 session-4.scope    <---- scope

    _cat  /sys/fs/cgroup/systemd/user.slice/user-1000.slice/session-4.scope/tasks   <---- задачи запущенные в этой сессии пользователя_


#####   Юниты systemd


Тип unit’а :  



- target --  ничего не описывает, группирует другие юниты  
      так же это уровни загрузки:  
        <span style="color:green"> _multi-user.target_</span> - текстовый уровень ( init 3 уровень )  
        <span style="color:green"> _graphical.target_</span> - графический уровень ( init 5 уровень)  
    возможность загружаться в target юнит, определяется наличием параметра <span style="color:red"> _"AllowIsolate=yes"_</span> в файле конфигурации юнита

        [Unit]
        Description=Multi-User System
        Documentation=man:systemd.special(7)
        Requires=basic.target
        Conflicts=rescue.service rescue.target
        After=basic.target rescue.service rescue.target
        AllowIsolate=yes


- service --  аналог демона (или то, что можно запустить)
- timer -- аналог cron (запуск другого юнита, default - *.se

Создание свооего сервиса. .service юниты

Создание свооего сервиса. .timer юниты


####  Значения секции [Timer]


[Создание .timer юнита ссылка на archlinux.org ](https://wiki.archlinux.org/index.php/Systemd_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)/Timers_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9))



    DOW YYYY-MM-DD HH:MM:SS <---- DOW день недели, необязательный параметр,  Год-Месяц-День Часы:Минуты:Секунды

                *-*-* *:*:30 <---- Параметры срабатывания расписания, каждые 30 секунд

  **OnActiveSec=          :** Время срабатывания таймера задаётся относительно момента активации таймера.

  **OnBootSec=            :** Время срабатывания таймера задаётся относительно момента загрузки системы.

  **OnStartupSec=         :** Время срабатывания таймера определяется относительно первого запуска менеджера служб. В случае с системными таймерами это очень похоже на OnBootSec= так как системный менеджер служб обычно запускается при загрузке очень рано. Подобные таймеры, преимущественно, ценны при использовании их с привязкой к менеджерам служб, относящимся к отдельным пользователям, так как такие менеджеры служб обычно запускаются только при первом входе пользователя в систему, а не в процессе загрузки системы.

  **OnUnitActiveSec=      :** Время срабатывания таймера задаётся относительно того времени, когда таймер, который должен быть активирован, был активирован в последний раз.

  **OnUnitInactiveSec=    :** Время срабатывания таймера определяется относительно того времени, когда таймер, который должен быть активирован, был в последний раз деактивирован.

  **OnCalendar=           :**	Такой таймер привязан к реальному времени и ориентируется на события календаря. Подробности о синтаксисе описаний событий календаря можно найти в справке по systemd.time(7). В остальном же семантика описаний таких таймеров похожа на таймеры OnActiveSec=. Это — именно такие таймеры systemd, которые сильнее всего похожи на те механизмы, которые применяются при настройке заданий cron.




####                      Значения секции [Service]


**Type=idle         :** <---- Тип сервиса idle. systemd перехватит стандартные потоки ввода-вывода и будет следить за жизнью процесса.

**Type=simple       :**

**Before=           :** <---- *Юниты, перечисленные в этой директиве, не будут запущены до тех пор, пока текущий юнит не будет отмечен как запущенный, если они будут активированы одновременно.*

**After=            :** <---- *Юниты, перечисленные в этой директиве, будут запущены до запуска текущего юнита.*


**Requires=         :** <---- *В этой директиве перечислены все юниты, от которых зависит этот юнит (служба или устройство). Перечисленные здесь юниты также должны успешно активироваться, иначе запуска юнита не будет. Эти юниты запускаются параллельно с текущим по умолчанию, если не указаны Before= или After=.*

**BindsTo=          :** <---- *Эта директива аналогична Requires=, но приводит к остановке запускаемого юнита, когда юнит от которого он зависил завершается.*

    Пример: Юнит logwatch.service, зависит от запуска createlog.service, и по окончании работы юнита  createlog.service, так же будет остановлен и logwatch.service
            [Unit]
            Description=Log watch, created by script genstring_h.sh
            BindsTo=createlog.service
            Before=createlog.service


###                                       4.Ограничение ресурсов ulimits vs systemd (cgroups)

1.  **man ulimit** || **man limits.conf**  <---- man по ограничениям ресурсов в ulimits. Ограничения в ulimits ставятся на каждый процесс, в systemd - на юнит, все дочерние процессы ограничиваются.
2.  **man systemd.exec**  <---- man ограничения в systemd.
3.  **man systemd.resource-control**  <---- man Лимиты systemd

Ограничения systemd используются в секции

    [Service]
    MemoryLimit=2G

 _/etc/systemd/system.conf_ <---- Значения по ограничениям сервисов, по умолчанию, можно задать в соответствующих строках файла:

    #DefaultLimitCPU=
    #DefaultLimitFSIZE=
    #DefaultLimitDATA=
    #DefaultLimitSTACK=
    #DefaultLimitCORE=
    #DefaultLimitRSS=
    #DefaultLimitNOFILE=
    #DefaultLimitAS=
    #DefaultLimitNPROC=
    #DefaultLimitMEMLOCK=
    #DefaultLimitLOCKS=
    #DefaultLimitSIGPENDING=
    #DefaultLimitMSGQUEUE=
    #DefaultLimitNICE=
    #DefaultLimitRTPRIO=
    #DefaultLimitRTTIME=



# JOURNALD. ШПАРГАЛКА ПО РАБОТЕ С JOURNALCTL.


Для начала, давайте убедимся что логи journald у нас не очищаются с каждой перезагрузкой сервера. В случае если на сервере имеется директория /run/log/journal/ и она не пуста, если директории /var/log/journal не существует и если команда journalctl --list-boots показывает только один пункт из списка, то скорее всего в этом случае journald настроен на временное хранение логов до ребута. Исправить эту ситуацию можно следующим образом…

1. Включаем постоянное хранение логов в конфиге /etc/systemd/journald.conf:

      [Journal]
      Storage=persistent

2. Создаём директорию для журналов и вводим её в работу:

      mkdir /var/log/journal
      systemd-tmpfiles --create --prefix /var/log/journal
      systemctl restart systemd-journald

Теперь наши логи будут храниться на диске и мы сможем обращаться к ним даже после перезагрузки.

3. Что бы логи не разрослись, имеет смысл настроить их ротацию, для этого у journalctl доступны параметры --vacuum-size и --vacuum-time.

Просмотрим общий размер логов:

      journalctl --disk-usage

Ограничим размер логов объёмом в 1Гб:

      journalctl --vacuum-size=1G

При необходимости, ограничим время хранения логов:

      journalctl --vacuum-time=1years

Если наши логи занимали 2Гб, при ограничении размера до 1Гб, система удалит самые старые логи. Аналогично и со временем хранения журналов. Дополнительную настройку лимитов можно выполнить в конфигурационном файле /etc/systemd/journald.conf.

##### Просмотр информации о логах.

Перейдём непосредственно к работе с логами. Команда, которая показывает нам список всех загрузок системы:

      journalctl --list-boots

Здесь мы получаем порядковый номер загрузки (0 — текущая, -1 — предыдущая и т. д.), ID загрузки и информацию о времени. Используя порядковый номер или ID мы можем обращаться к конкретному логу с помощью ключа -b

      journalctl -b 20994413abfc41c89defcaaeb1130d62
      journalctl -b -3

Обратившись к логу, мы получаем всё его содержимое. Неплохо было бы отфильтровать только нужные для нас данные.

##### Выборка по имени юнита.

Мы можем указывать конкретный юнит, сообщения которого из лога нам нужны. Например, мы хотим получить все сообщения от юнита httpd:

      journalctl -u httpd.service

Либо получить сообщения из лога сразу от двух юнитов httpd и mysql:

      journalctl -u httpd.service -u mysql.service

.service в имени юнитов можно не дописывать. Команда ниже даст аналогичный предыдущей результат:

      journalctl -u httpd -u mysql

##### Выборка по номеру PID, UID, GID, по пути к бинарнику.

Информацию из журнала можно выбрать по id пользователя или группы в системе, либо по номеру процесса. Для начала посмотрим у каких PID, UID и GID в журнале есть записи, сделать это можно командой journalctl -F

      journalctl -F _UID
      journalctl -F _PID
      journalctl -F _GID

Допустим на нужно получить всё что в журнал записала программа с PID 2093:

      journalctl _PID=2093

Либо у нас в системе есть пользователь с UID 1395 и мы хотим посмотреть что есть в журналах от него:

      journalctl _UID=1395

Аналогично и для группы, например GID 99:

      journalctl _GID=99

Сообщения от ядра мы можем показать отдельной командой:

      journalctl -k
      journalctl --dmesg
      journalctl -k -b -3
      journalctl --dmesg -b 20994413abfc41c89defcaaeb1130d62

Сообщения из журнала от конкретного бинарника мы так же можем получить отдельно. Например, сообщения от /usr/sbin/pure-ftpd:

      journalctl /usr/sbin/pure-ftpd
      journalctl _EXE=/usr/sbin/pure-ftpd

##### Использование временных отрезков.

Иногда, в ходе исследования какой-либо проблемы, необходимо получить логи только за определённый промежуток времени. Для этого в journalctl предусмотрены ключи --since и --until. В качестве значений для этих ключей могут использоваться:

- Формат YYYY-MM-DD HH:MM:SS

      journalctl --since "2017-05-05 00:01" --until "2017-05-06 01:40"

- Слова «yesterday», «today», «tomorrow», «now»:

      journalctl --since "yesterday" --until "2017-05-06 01:40"

- Удобочитаемые выражения вида:

      journalctl --since "10 hours ago"
      journalctl --since "1 minute ago"
      journalctl --since "50 minute ago" --until "5 minute ago"

##### Фильтрация по приоритету сообщений.

Journald использует аналогичные syslog уровни сообщений. При фильтрации мы можем использовать либо имя приоритета, либо соответствующее имени число (далее от большего к меньшему):

0: emerg
1: alert
2: crit
3: err
4: warning
5: notice
6: info
7: debug

Так например, просмотреть сообщения уровня err, для предыдущей загрузки мы можем командой:

      journalctl -p err -b -1

Ошибки, которые NetworkManager оставлял в логе до перезагрузки можно увидеть командой:

      journalctl -p err -b -1 -u NetworkManager

##### Стандартный вывод для сообщений и аналог tail.

По умолчанию, journalctl выводит сообщения с помощью утилиты less. Это не всегда бывает удобно. Например, если мы хотим использовать grep для дополнительной фильтрации, имеет смысл направить сообщения от journalctl сразу на стандартный вывод. Для этого предусмотрен отдельный параметр:

      journalclt --no-pager

Так же, pager можно задать переменной:

export SYSTEMD_PAGER=cat

Администраторы привыкли использовать tail в повседневной работе с логами. В journalctl имеются аналогичные параметры, с помощью которых можно отобразить несколько последних строк лога, либо и вовсе следить за логом в реальном времени. Мы так же можем передать дополнительные параметры для уточнения правила фильтрации:

      journalctl -n 50
      journalctl -f
      journalctl -f -u NetworkManager
