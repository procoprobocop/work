#!/bin/bash

# Установка службы Auditd
echo "Установка службы Auditd..."
sudo apt-get install -y auditd

# Запуск и включение службы
echo "Запуск и включение службы Auditd..."
sudo systemctl start auditd
sudo systemctl enable auditd

# Настройка параметров конфигурационного файла
echo "Настройка параметров конфигурационного файла..."
sudo sed -i 's/^max_log_file.*/max_log_file = 100/g' /etc/audit/auditd.conf
sudo sed -i 's/^num_logs.*/num_logs = 5/g' /etc/audit/auditd.conf
sudo sed -i 's/^log_file.*/log_file = \/var\/log\/audit\/audit.log/g' /etc/audit/auditd.conf
sudo sed -i 's/^log_group.*/log_group = root/g' /etc/audit/auditd.conf

# Настройка правил регистрации событий безопасности
echo "Настройка правил регистрации событий безопасности..."
sudo cp /etc/audit/audit.rules /etc/audit/audit.rules.backup

# Добавление правил из таблицы 1
sudo cat << EOF >> /etc/audit/audit.rules

# Отслеживание изменений в директории или файле
-w /var/log -p w -k var_log_changes

# Аудит пользователей, групп, базы данных паролей
-w /etc/group -p wa -k etcgroup
-w /etc/passwd -p wa -k etcpasswd
-w /etc/gshadow -k etcgroup
-w /etc/shadow -k etcpasswd
-w /etc/security/opasswd -k opasswd
-w /etc/adduser.conf -k adduserconf

# Аудит изменений в файле Sudoers
-w /etc/sudoers -p wa -k actions

# Аудит паролей
-w /usr/bin/passwd -p x -k passwd_modification
-w /usr/bin/gpasswd -p x -k gpasswd_modification

# Аудит изменения идентификаторов групп и пользователей
-w /usr/sbin/groupadd -p x -k group_modification
-w /usr/sbin/groupmod -p x -k group_modification
-w /usr/sbin/addgroup -p x -k group_modification
-w /usr/sbin/useradd -p x -k user_modification
-w /usr/sbin/usermod -p x -k user_modification
-w /usr/sbin/adduser -p x -k user_modification

# Аудит конфигурации и входов
-w /etc/login.defs -p wa -k login
-w /etc/securetty -p wa -k login
-w /var/log/faillog -p wa -k login
-w /var/log/lastlog -p wa -k login
-w /var/log/tallylog -p wa -k login

# Отслеживание запуска определенного приложения
-a exit,always -F path=/usr/bin/myapp -F perm=x -k myapp_execution

# Отслеживание системных вызовов
-a exit,always -F arch=b64 -S execve -F uid=0 -k authentication_events
-a exit,always -F arch=b32 -S execve -F uid=0 -k authentication_events

# Отслеживание сетевых подключений
-a exit,always -F arch=b64 -S bind -S connect -F success=0 -k network_events

# Запись в журнал аудита при подключении устройства USB
-w /dev/bus/usb -p rwxa -k usb
EOF

# Перезагрузка службы
echo "Перезагрузка службы Auditd..."
sudo systemctl restart auditd

echo "Настройка регистрации событий безопасности завершена."
