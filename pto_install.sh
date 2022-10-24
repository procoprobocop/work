#!/bin/bash
#создаём временную переменную "$PASSWORD" для подставления пароля администратора
PASSWORD=$(whiptail --title "Ввод пароля" --passwordbox "Введите ваш пароль и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
#проверка на наличие пользователя в группе администраторов
echo "Производится обновление системы"
sleep 3
echo "$PASSWORD" | sudo -S dnf -y install kernel-lt-5.15.35-1.el7.3.x86_64 kernel-lt-tools-5.15.35-1.el7.3.x86_64 kernel-lt-devel-5.15.35-1.el7.3.x86_64 kernel-lt-headers-5.15.35-1.el7.3.x86_64
echo "$PASSWORD" | sudo -S dnf -y update && sudo -S dnf -y upgrade && sudo -S dnf -y autoremove && uname -r
else
	echo "Вы выбрали отмену."
fi
#
#
#
echo "Настройка SSH"
sleep 3
#в файле hosts.allow разрешаем доступ ip-адресам которые будут подключаться к настриваемой машине по протоколу SSH
IPSSH=$(whiptail --title "Настройка доступа SSH" --inputbox "Через запятую, разделяя пробелом введите ip-адреса, которые будут подключаться к настриваемой машине по протоколу SSH (пример: 10.10.73.16, 10.10.73.17 и т.д.)" 10 60 10.10.73.16,  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Вы предоставили доступ следующим ip-адресам:" $IPSSH
echo "$PASSWORD" | sudo -S sh -c "echo 'sshd: $IPSSH' >> /etc/hosts.allow"
#в файле hosts.deny запрещаем подключение к настраиваемой машине всем ip-адресам не включённым список hosts.allow 
echo "$PASSWORD" | sudo -S sh -c "echo 'sshd: ALL' >> /etc/hosts.deny"
#меняем порт подключения 22 на 2002
echo "$PASSWORD" | sudo -S sed -i '17d' /etc/ssh/sshd_config
echo "$PASSWORD" | sudo -S perl -i -pe 'print "Port 2002\n" if $. == 17' /etc/ssh/sshd_config
#открываем доступ только по протоколу IPv4
echo "$PASSWORD" | sudo -S sed -i '18d' /etc/ssh/sshd_config
echo "$PASSWORD" | sudo -S perl -i -pe 'print "AddressFamily inet\n" if $. == 18' /etc/ssh/sshd_config
#запрещаем подключение от учётной записи root
echo "$PASSWORD" | sudo -S sed -i '36d' /etc/ssh/sshd_config
echo "$PASSWORD" | sudo -S perl -i -pe 'print "PermitRootLogin no\n" if $. == 36' /etc/ssh/sshd_config
#добавляем порт 2002 в selinux и перезапускаем службу sshd 
echo "$PASSWORD" | sudo -S semanage port -a -t ssh_port_t -p tcp 2002
echo "$PASSWORD" | sudo -S systemctl restart sshd
else
echo "Вы выбрали отмену."
fi
#
#
#
echo "Установка и настройка VNC"
sleep 3
#создаём временную переменную "$PASSWORD" для подставления пароля root
PASSROOT=$(whiptail --title "Ввод пароля root" --passwordbox "Введите пароль от учётки ROOT и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
#устанавливаем программу x11vnc
echo "$PASSROOT" | sudo -S -u root dnf -y install x11vnc
else
	echo "Вы выбрали отмену."
fi
#создаём временную переменную $PASSVNC для подставления пароля
PASSVNC=$(whiptail --title "Ввод пароля" --passwordbox "Задайте пароль для доступа по VNC и нажмите ОК для продолжения." 10 60 3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
#задаём пароль на вход
echo "$PASSROOT" | sudo -S -u root x11vnc -storepasswd $PASSVNC /etc/vncpasswd
else
echo "Вы выбрали отмену."
fi
#выдаём права на чтение и выполнение для файла с паролем
echo "$PASSROOT" | sudo -S -u root chmod 544 /etc/vncpasswd
#скачиваем и подгружаем сервисный файл с настройками
echo "$PASSROOT" | sudo -S -u root cd /lib/systemd/system/
#создаём службу для подключения по протоколу vnc
IPVNC=$(whiptail --title "Настройка доступа VNC" --inputbox "Через запятую, без пробелов введите ip-адреса, которые будут подключаться к настриваемой машине по протоколу VNC (пример: 10.10.73.16,10.10.73.17 и т.д.)" 10 60 10.10.73.16,  3>&1 1>&2 2>&3)
exitstatus=$?
if [ $exitstatus = 0 ]; then
echo "Вы предоставили доступ следующим ip-адресам:" $IPVNC
sleep 5
echo "$PASSROOT" | sudo -S -u root echo -e "[Unit]\nDescription=x11vnc server for GDM\nAfter=display-manager.service\n[Service]\nExecStart=/usr/bin/x11vnc -allow $IPVNC -many -shared -forever -nomodtweak -capslock -display :0 -auth guess -noxdamage -rfbauth /etc/vncpasswd\nRestart=on-failure\nRestartSec=3\n[Install]\nWantedBy=graphical.target" > /lib/systemd/system/x11vnc.service
#даём файлу x11vnc.service права на выполнение
echo "$PASSROOT" | sudo -S -u root chmod ugo+x /lib/systemd/system/x11vnc.service
cd
#перезагружаем демона, включаем службу в автозагрузку, запускаем и проверяем статус
echo "$PASSROOT" | sudo -S -u root systemctl daemon-reload
echo "$PASSROOT" | sudo -S -u root systemctl enable x11vnc.service
echo "$PASSROOT" | sudo -S -u root systemctl restart x11vnc.service
echo "$PASSROOT" | sudo -S -u root systemctl status x11vnc.service
else
echo "Вы выбрали отмену."
fi
#
#
#
echo "Производится настройка Disk2"
sleep 3
#создаём таблицу разделов в формате gpt
echo "$PASSWORD" | sudo -S parted /dev/sdb mktable gpt
#создаём раздел диска sdb, который будет называться sdb1 с файловой системой ext4 и отводим ему 100% места на диске
echo "$PASSWORD" | sudo -S parted /dev/sdb mkpart primary ext4 0% 100% 
#форматируем созданный раздел
echo "$PASSWORD" | sudo -S mkfs.ext4 /dev/sdb1
#создаём директорию Disk2, в которую смонтируем наш HDD
echo "$PASSWORD" | sudo -S mkdir /mnt/Disk2
#монтируем созданный диск
echo "$PASSWORD" | sudo -S mount /mnt/Disk2
#задаём директории Disk2 в которую примонтирован HDD доступ на чтение/запись/выполнение для всех: 
echo "$PASSWORD" | sudo -S chmod 777 /mnt/Disk2/
#создаём символическую ссылку диска на рабочем столе локального пользователя:
echo "$PASSWORD" | sudo -S ln -s /mnt/Disk2	/home/$USER/Рабочий\ стол/
#редактируем файл /etc/fstab монтируя вновь созданный раздел диска /dev/sdb1 в директорию Disk2
echo "$PASSWORD" | sudo -S sh -c "echo '/dev/sdb1	/mnt/Disk2	ext4	defaults	1 2' >> /etc/fstab"
#
#
#
echo "Добавляем компьютер в домен"
sleep 3
#устанавливаем правильный часовой пояс
echo "$PASSWORD" | sudo timedatectl set-timezone Asia/Yekaterinburg
timedatectl | grep "Time zone"
date
chronyc tracking
#проверяем DNS и разрешение имён
nslookup 10.10.73.5
nslookup 10.10.73.9
nslookup PTO.local
#меняем локализацию на английскую. Это нужно, если у вас в пароле администратора домена присутствуют специальные символы: !@#$%^ и т.д..
#после перезагрузки локализация снова сбросится на русскую
export LANG=en_US.UTF-8
#проверяем доступность домена
realm discover PTO.local
#устанавливаем программу добавления в домен
echo "$PASSWORD" | sudo -S dnf -y install join-to-domain
#запускаем скрипт добавления в домен
echo "$PASSWORD" | sudo join-to-domain.sh
sleep 10
#проверяем доступность домена
realm list
#проверяем новое имя компьютера
hostname
#создаём переменную DOMAIN и присваиваем ей значение dns-имени домена
DOMAIN=$(dnsdomainname -d)
realm discover -v $DOMAIN
#даём группам "Администраторы домена" и "Пользователи домена" права выполнения команд от имени суперпользователя 
echo "$PASSROOT" | sudo -S -u root perl -i -pe 'print "%Администраторы\\ домена  ALL=(ALL)       ALL\n" if $. == 108' sudoers
echo "$PASSROOT" | sudo -S -u root perl -i -pe 'print "%Пользователи\\ домена  ALL=(ALL)       ALL\n" if $. == 109' sudoers
#перезагружаемся, иначе магия не сработает
if (whiptail --title "Требуется перезагрузка системы" --yesno "Перезагрузить систему сейчас?" 10 60) then
	echo "$PASSWORD" | sudo reboot
else
	echo "Не забудьте перезагрузить систему"
fi
#
#
#






