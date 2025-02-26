#!/bin/bash

LOG_FILE="/tmp/version_log.txt"

declare -A LOCAL_VERSION_FILES
declare -A REMOTE_VERSION_URLS

# Ürünlerin versiyon dosyaları ve uzak URL'leri
LOCAL_VERSION_FILES=(
    [urun1]="/tmp/version_urun1.txt"
    [urun2]="/tmp/version_urun2.txt"
)

REMOTE_VERSION_URLS=(
    [urun1]="http://192.168.1.29:8081/repository/cloud-images-hosted/version_urun1.txt"
    [urun2]="http://192.168.1.29:8081/repository/cloud-images-hosted/version_urun2.txt"
)

# Önceki versiyonları bellekte tutmak için değişken tanımla
declare -A previous_versions
previous_versions=(
    [urun1]=""
    [urun2]=""
)

# Sonsuz döngü
while true; do
    for urun in "${!LOCAL_VERSION_FILES[@]}"; do
        LOCAL_VERSION_FILE="${LOCAL_VERSION_FILES[$urun]}"
        REMOTE_VERSION_URL="${REMOTE_VERSION_URLS[$urun]}"
        
        # Uzak versiyonu oku (önceki sıfırları koruyarak)
        remote_version=$(curl -s "$REMOTE_VERSION_URL" | tr -d '\r')
        
        # Yerel versiyonu oku (önceki sıfırları koruyarak)
        if [[ -f "$LOCAL_VERSION_FILE" ]]; then
            local_version=$(cat "$LOCAL_VERSION_FILE" | tr -d '\r')
        else
            local_version=""
        fi
        
        # Eğer önceki versiyon boşsa, yerel versiyonu ata
        if [[ -z "${previous_versions[$urun]}" ]]; then
            previous_versions[$urun]="$local_version"
        fi
        
        # Versiyonlar farklıysa güncelle ve log kaydı ekle
        if [[ "${previous_versions[$urun]}" != "$remote_version" ]]; then
            timestamp=$(date +"%Y-%m-%d %H:%M:%S")
            log_entry="$timestamp, \"${previous_versions[$urun]}\" -> \"$remote_version\" ($urun)"
            echo "$log_entry" >> "$LOG_FILE"
            echo "$remote_version" > "$LOCAL_VERSION_FILE"
            echo "Version updated: $log_entry"

            # Bellekteki eski versiyonu güncelle
            previous_versions[$urun]="$remote_version"
        fi
    done
    sleep 5
done