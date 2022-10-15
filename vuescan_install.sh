#скачиваем и распаковываем
wget https://www.hamrick.com/files/vuex6497.tgz
gunzip vuex6497.tgz
tar -xvf vuex6497.tar
#копируем в общую директорию
sudo cp -r VueScan /usr/share
#создаём переменную DOMAIN и присваиваем ей значение DNS-имени домена
DOMAIN=$(dnsdomainname -d)
#создаём ярлык запуска на рабочем столе
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nTerminal=false\nIcon=/usr/share/VueScan/vuescan.svg\nName[ru_RU]=VueScan\nExec=/usr/share/VueScan/vuescan\nName=VueScan" > /home/$USER@$DOMAIN/Рабочий\ стол/VueScan.desktop
#делаем файл исполняемым
chmod ugo+x /home/$USER@$DOMAIN/Рабочий\ стол/VueScan.desktop
#обновить иконки
sudo gtk-update-icon-cache -ft /usr/share/icons/hicolor
