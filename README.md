# Script for Linux 
#  применимы для моноблоков iCL Si101.Mi
Перед запуском скриптов выполните следующее:
1. В контроллере домена, в папке Computers удалите настраиваемый компьютер если он там уже есть (иначе будут проблемы с добавлением в домен).
2. Скачайте папку со скриптами к себе на флешку \\10.10.73.15\Public\repo\linux_script. Если будет ставиться VipNet скиньте на флешку dst и пароль.
3. После чистой установки Ред ОС, подключите флешку в моноблок и скопируйте папку со скриптами в домашнюю директорию
4. Откройте терминал и введите:
cd /home/LocalAdmin/linux_script
sudo chmod ugo+x script_1_disk script_2_domen script_3_vnc script_4_prog
#Запуск скриптов
5. Откройте терминал и введите:
cd /home/LocalAdmin/linux_script
./script_1_disk
#Будет выполнен запуск скрипта, после чего произойдёт перезагрузка
6. Откройте терминал и введите:
cd /home/LocalAdmin/linux_script
./script_2_domen
#Вам будет предложено добавить компьютер в домен, после чего произойдёт перезагрузка
7. Авторизуйтесь под пользователем домена.
Откройте терминал и введите:
su -
cd /mnt/Disk2/linux_script
./script_3_vnc
#Произойдёт установка и настройка VNC от имени root. 
chmod ugo+rwx script_1_disk script_2_domen script_3_vnc script_4_prog
#По завершении всех действий выйдитите из root.
exit
cd /mnt/Disk2/linux_script
vim script_4_prog
#Комментируем знаком # те программы, которые пользователю не понадобятся (например VipNet, 1C, КРИПТО-ПРО и т.д.). 
#Закрываем, сохраняем, запускаем скрипт.
./script_4_prog
#Будет выполнена установка и настройка оставшихся программ, после чего произойдёт перезагрузка.
#Некоторые настройки, например пользователя в Spark или 1C придётся донастраивать самостоятельно.

#Запускать один скрипт дважды не рекомендуется!

