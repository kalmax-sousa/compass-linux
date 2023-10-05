#!/bin/bash
timestamp=$(date +"%Y-%m-%d %T")
service_name="Apache"
status=""

if systemctl is-active --quiet httpd; then # Verifica se o Apache está funcionando
    status="Online"
else
    status="Offline"
fi

# Cria/Atualiza arquivo de status
echo "$timestamp - $service_name - Status: $status" >> /mnt/Kalmax/status_$status.txt