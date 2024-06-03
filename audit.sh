#!/bin/bash

# Установка пакета auditd
apt-get install -y auditd

# Запуск и включение службы auditd
systemctl start auditd
systemctl enable auditd

# Настройка параметров конфигурационного файла auditd.conf
cat << EOF > /etc/audit/auditd.conf
max_log_file = 50
num_logs = 5
log_file = /var/log/audit/audit.log
log_group = root
EOF

# Настройка правил регистрации событий безопасности
cat << EOF > /etc/audit/rules.d/security_events.rules
# Отслеживание изменений в директории /var/log
-w /var/log -p w -k var_log_changes

# Аудит пользователей, групп, базы данных паролей
-w /etc/group -p wa -k etcgroup
-w /etc/passwd -p wa -k etcpasswd
-w /etc/gshadow -k etcgroup
-w /etc/shadow -k etcpasswd
-w /etc/security/opasswd -k opasswd
-w /etc/adduser.conf -k adduserconf

# Аудит изменений в файле sudoers
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

# Перезагрузка службы auditd для применения новых правил
systemctl restart auditd
