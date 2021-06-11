#Script for Linux 

#применимы для моноблоков iCL Si101.Mi и Ред ОС 7.3
__________________________________________________________________________________

#Подготовка к запуску скриптов

1. В контроллере домена, в папке Computers удалите настраиваемый компьютер если он там есть (иначе будут проблемы с добавлением в домен).

2. Если будет ставиться VipNet заранее скиньте на флешку dst-файл и пароль.

3. Откройте терминал и введите:

git clone https://github.com/procoprobocop/work.git

cd work/ 

chmod ugo+x script_1_disk script_2_domen script_3_vnc script_4_prog

___________________________________________________________________________________

#Запуск скриптов

4. Откройте терминал и введите:

./script_1_disk

#Будет выполнен запуск скрипта, после чего произойдёт перезагрузка

5. Откройте терминал и введите:

cd work/

./script_2_domen

#Вам будет предложено добавить компьютер в домен, после чего произойдёт перезагрузка

6. Авторизуйтесь под пользователем домена.

Откройте терминал и введите:

su -

#укажите пароль от root

cd /mnt/Disk2/work/

./script_3_vnc

#после выполнения скрипта нажмите "q"

chmod ugo+rwx script_4_prog

exit

cd /mnt/Disk2/work/

vim (или nano) script_4_prog

#Комментируем знаком # те программы, которые пользователю не понадобятся (например VipNet, 1C, КРИПТО-ПРО и т.д.).
#Cохраняем, запускаем скрипт:

./script_4_prog

#Будет выполнена установка и настройка оставшихся программ, после чего произойдёт перезагрузка.

#Некоторые настройки, например пользователя в Spark или 1C придётся донастраивать самостоятельно.
_____________________________________________________________________________________

#P.S: Запускать один скрипт дважды не рекомендуется!

