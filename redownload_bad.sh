#!/bin/bash
# Objects365 Download Tools - ITLAN (c) 2026
# MIT License - see LICENSE.md for details

DOWNLOAD_DIR="object365/images/train"
LOG_FILE="redownload_bad.log"

# Список битых архивов из проверки скриптом check_targz.sh
BAD_ARCHIVES=(
    12 13 14 25 26 27 28 29 30 34 35 37 38 40 42 43 44 46 47 49 50
)

echo "========================================="
echo "ПЕРЕЗАЛИВКА БИТЫХ АРХИВОВ OBJECTS365"
echo "========================================="
echo "Всего битых архивов: ${#BAD_ARCHIVES[@]}"
echo "Номера: ${BAD_ARCHIVES[@]}"
echo "========================================="
echo ""

# Создаем лог файл
> "$LOG_FILE"

# Счетчики
TOTAL=${#BAD_ARCHIVES[@]}
SUCCESS=0
FAILED=0

# Функция загрузки с разными методами
download_archive() {
    local i=$1
    local url="https://dorc.ks3-cn-beijing.ksyun.com/data-set/2020Objects365%E6%95%B0%E6%8D%AE%E9%9B%86/train/patch${i}.tar.gz"
    local output="$DOWNLOAD_DIR/patch${i}.tar.gz"
    
    echo "[$(date '+%H:%M:%S')] Загрузка patch${i}.tar.gz..."
    
    # Удаляем старый битый файл
    rm -f "$output" "$DOWNLOAD_DIR/patch${i}.tar.gz.aria2" 2>/dev/null
    
    # Пробуем разные методы по порядку
    # Метод 1: aria2c с HTTPS
    aria2c -x 8 -s 8 \
        --continue=true \
        --timeout=300 \
        --connect-timeout=60 \
        --max-tries=3 \
        --retry-wait=10 \
        --check-certificate=false \
        --console-log-level=error \
        "$url" \
        -d "$DOWNLOAD_DIR" \
        -o "patch${i}.tar.gz" 2>/dev/null
    
    # Проверяем результат
    if [ -f "$output" ] && tar tzf "$output" &>/dev/null; then
        size=$(stat -c%s "$output" 2>/dev/null)
        size_gb=$(echo "scale=2; $size/1024/1024/1024" | bc)
        echo "  ✅ patch${i}.tar.gz загружен (${size_gb}GB)"
        return 0
    fi
    
    # Метод 2: wget если aria2c не сработал
    echo "  ⚠️ aria2c не сработал, пробую wget..."
    wget --no-check-certificate \
         --timeout=300 \
         --tries=3 \
         -c \
         -O "$output" \
         "$url" 2>/dev/null
    
    if [ -f "$output" ] && tar tzf "$output" &>/dev/null; then
        size=$(stat -c%s "$output" 2>/dev/null)
        size_gb=$(echo "scale=2; $size/1024/1024/1024" | bc)
        echo "  ✅ patch${i}.tar.gz загружен через wget (${size_gb}GB)"
        return 0
    fi
    
    # Метод 3: curl
    echo "  ⚠️ wget не сработал, пробую curl..."
    curl -L --insecure --retry 3 --connect-timeout 60 \
         -o "$output" "$url" 2>/dev/null
    
    if [ -f "$output" ] && tar tzf "$output" &>/dev/null; then
        size=$(stat -c%s "$output" 2>/dev/null)
        size_gb=$(echo "scale=2; $size/1024/1024/1024" | bc)
        echo "  ✅ patch${i}.tar.gz загружен через curl (${size_gb}GB)"
        return 0
    fi
    
    return 1
}

# Загружаем каждый битый архив
for i in "${BAD_ARCHIVES[@]}"; do
    echo "-----------------------------------------"
    echo "Архив $((SUCCESS+FAILED+1))/$TOTAL: patch${i}.tar.gz"
    
    if download_archive $i; then
        SUCCESS=$((SUCCESS + 1))
        echo "✅ Успешно: patch${i}.tar.gz" >> "$LOG_FILE"
    else
        FAILED=$((FAILED + 1))
        echo "❌ Не удалось: patch${i}.tar.gz" >> "$LOG_FILE"
    fi
    
    # Пауза между загрузками
    echo "Ожидание 5 секунд..."
    sleep 5
done

# Итоговый отчет
echo ""
echo "========================================="
echo "ПЕРЕЗАЛИВКА ЗАВЕРШЕНА"
echo "========================================="
echo "✅ Успешно загружено: $SUCCESS из $TOTAL"
echo "❌ Не удалось загрузить: $FAILED из $TOTAL"
echo "========================================="

# Если остались проблемные
if [ $FAILED -gt 0 ]; then
    echo ""
    echo "Не удалось загрузить:"
    for i in "${BAD_ARCHIVES[@]}"; do
        if [ ! -f "$DOWNLOAD_DIR/patch${i}.tar.gz" ] || ! tar tzf "$DOWNLOAD_DIR/patch${i}.tar.gz" &>/dev/null; then
            echo "  patch${i}.tar.gz"
        fi
    done
fi

echo "Лог сохранен в: $LOG_FILE"
