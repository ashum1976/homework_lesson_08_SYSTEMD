
#                                                               1.  Система инициализации Systemd







В системах работающих под управлением systemd, /sbin/init ---> символическая ссылка /sbin/init -> ../lib/systemd/systemd 












##                                                              2. ДЗ homework_lesson_08_SYSTEMD








###                                                             3. Полезные команды, ссылки.

1.              [andrey@nix64amd lesson_08_SYSTEMD]$ systemctl cat sshd   <----- просмотр содержимого файла   выбранного юнита  ( systemd )                      
            
                # /usr/lib/systemd/system/sshd.service
                [Unit]
                Description=OpenSSH server daemon
                Documentation=man:sshd(8) man:sshd_config(5)
                After=network.target sshd-keygen.target
                Wants=sshd-keygen.target

                [Service]
                Type=notify
                EnvironmentFile=-/etc/crypto-policies/back-ends/opensshserver.config     <----- Тут переменная $CRYPTO_POLICY
                EnvironmentFile=-/etc/sysconfig/sshd
                ExecStart=/usr/sbin/sshd -D $OPTIONS $CRYPTO_POLICY
                ExecReload=/bin/kill -HUP $MAINPID
                KillMode=process
                Restart=on-failure
                RestartSec=42s

                [Install]
                WantedBy=multi-user.target

3.              systemctl daemon-reexec   <----   перечитать конфиг файл /etc/systemd/system.conf, при изменении конфигурации.

4.              systemctl daemon-reload   <---- при изменении параметров запуска юнита, перечитать все юниты.


5.                                
                 /etc/systemd/system.conf   <------ параметры конфигурации systemd
                    
                    Для отображения в выводе команды  systemd-cgtop учёта ресурсов включить параметры: 
                    
                    DefaultCPUAccounting=yes
                    DefaultIOAccounting=yes
                    DefaultIPAccounting=yes
                    DefaultBlockIOAccounting=yes
                
                
                
                
                
####            Man systemd 

1.              man systemd.index       <------ полный man по всем параметрам и значениям Systemd
2.              man systemd-system.conf  <----- man по параметрам конфигурационного файла /etc/systemd/system.conf
3.              man systemd.unit               <----- man по типам юнитов



####        Анализ работы, состояния, загрузки в systemd

1.              ps -axf                           <------- просмотр дерева процессов

2.              systemctl status            <------- состояние системы, дерево юнитов systemd -----
                                                                                                                                                   |
                                                                                                                                                   |  
*                                [root@nix64amd ~]# systemctl --failed            <---- просмотр юнитов, запуск которых завершился с ошибкой

                                        UNIT           LOAD   ACTIVE SUB    DESCRIPTION
                                        ● kdump.service  loaded failed failed Crash recovery kernel arming
                                        ● mcelog.service loaded failed failed Machine Check Exception Logging Daemon

                                        LOAD   = Reflects whether the unit definition was properly loaded.
                                        ACTIVE = The high-level unit activation state, i.e. generalization of SUB.
                                        SUB    = The low-level unit activation state, values depend on unit type.

                                        2 loaded units listed. Pass --all to see loaded but inactive units, too.
                                        To show all installed unit files use 'systemctl list-unit-files'        

                                    
                                    [root@nix64amd ~]# systemctl show sshd          <------ просмотр полной конфигурации параметров преданных сервису и сгенерированных sustemd для этого сервиса
                                    
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
                                       .....................
                                       .....................
                                       .....................
                                       ..................... 
                                       
                                    
                                    
3.                [root@nix64amd ~]# systemd-cgls                 <------- состояние системы, дерево юнитов systemd

4.               [root@nix64amd ~]# systemd-analyze  <------ анализ времени загрузки [ time]

                    Startup finished in 1.289s (kernel) + 27.636s (initrd) + 46.935s (userspace) = 1min 15.862s
                    graphical.target reached after 46.924s in userspace

5.               [root@nix64amd ~]# systemd-analyze critical-chain             <------- анализ, что грузилось с наибольшей задержкой
                
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
                    └─iscsiuio.socket @15.526s
                    └─sysinit.target @15.494s
                    └─systemd-update-utmp.service @15.474s +20ms
                    └─auditd.service @15.223s +249ms
                    └─systemd-tmpfiles-setup.service @14.821s +398ms
                    └─import-state.service @14.701s +119ms
                    └─local-fs.target @14.697s
                    └─run-user-42.mount @30.112s
                    └─local-fs-pre.target @7.150s
                    └─systemd-tmpfiles-setup-dev.service @3.306s +516ms
                    └─kmod-static-nodes.service @2.789s +288ms
                    └─systemd-journald.socket
                    └─-.mount
                    └─system.slice
                    └─-.slice
                
                
6.  [root@nix64amd ~]# systemd-analyze blame

    *21.405s dracut-initqueue.service*
    *19.365s systemd-cryptsetup@luks\x2daae6ec35\x2d0b1b\x2d48cb\x2dbfee\x2d5ef2c680c24e.service*
    *18.087s plymouth-quit-wait.service*
    *17.399s systemd-cryptsetup@luks\x2d11d3998e\x2d534f\x2d4191\x2d8f34\x2d95d917ae2f35.service*
    *10.457s dnf-makecache.service*
    *8.004s udisks2.service*
    *6.484s systemd-cryptsetup@luks\x2d460961c9\x2d95ca\x2d4ad9\x2dbeea\x2d564b275a47c5.service*


7.  [root@nix64amd ~]# systemctl list-dependencies             <------- дерево юнитов условие запуска которых выполняется (зелёный цвет), для тех у кого не выполняется (красный). 
                    

                    
8.  [root@nix64amd ~]# systemd-cgtop             <-------- Аналог top с более простым вариантом отображения используемых ресурсов
                            
     [root@nix64amd ~]# systemd-cgtop  --depth  <------ глубина отображения вложений от корня cgroups

   Групировка объектов в systemd
                
  1.  **slice  - объект, представляющий иерархию (сервиса / сессии)**
                    
   [root@nix64amd ~]# ls -l /sys/fs/cgroup/systemd/*.slice     < -------  slice в systemd находятся в этой директории

                    
  2.  **scope - объект в slice, группирующий процессы**

                            
   [root@nix64amd ~]# ls -l /sys/fs/cgroup/systemd/user.slice/user-1000.slice/    <---- scope внутри slice ( на примере пользовательского, user id 1000)
    
    итого 0
     .................
    .................
    drwxr-xr-x  2 root   root   0 мар  2 08:06 session-2.scope    <---- scope
    drwxr-xr-x  2 root   root   0 мар  2 08:07 session-4.scope    <---- scope
                           
    cat  /sys/fs/cgroup/systemd/user.slice/user-1000.slice/session-4.scope/tasks   <---- задачи запущенные в этой сессии пользователя 
                            

####        Юниты systemd

Тип | unit’а | Описание
target | ничего не описывает, группирует другие юниты
service | аналог демона (или то, что можно запустить)
timer | аналог cron (запуск другого юнита, default - *.se





