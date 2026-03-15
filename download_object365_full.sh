#!/bin/bash
# Objects365 Download Tools - ITLAN (c) 2026
# MIT License - see LICENSE.md for details

DOWNLOAD_DIR="object365/images/train"
mkdir -p "$DOWNLOAD_DIR"

# Количество архивов
START=0
END=50

# Создаем лог файл
LOG_FILE="download_objects365.log"
echo "=== Загрузка начата $(date) ===" > "$LOG_FILE"

# Функция для загрузки одного архива с агрессивными таймаутами
download_patch() { 
    local i=$1
    local url="https://dorc.ks3-cn-beijing.ksyun.com/data-set/2020Objects365%E6%95%B0%E6%8D%AE%E9%9B%86/train/patch${i}.tar.gz"
    local http_url="http://dorc.ks3-cn-beijing.ksyun.com/data-set/2020Objects365%E6%95%B0%E6%8D%AE%E9%9B%86/train/patch${i}.tar.gz"
    local output="${DOWNLOAD_DIR}/patch${i}.tar.gz"
    local max_retries=10
    local retry_count=0
    local ssl_retry_count=0
    local method_used=""
    
    # Пропускаем если файл уже существует и имеет нормальный размер (>3GB)
    if [ -f "$output" ]; then
        local size=$(stat -c%s "$output" 2>/dev/null || echo 0)
        if [ $size -gt 3000000000 ]; then
            echo "[$(date '+%H:%M:%S')] ✅ patch${i}.tar.gz уже существует (размер: $(numfmt --to=iec $size 2>/dev/null || echo "$size байт"))"
            echo "$(date): patch${i}.tar.gz уже существует, размер: $size" >> "$LOG_FILE"
            return 0
        else
            echo "[$(date '+%H:%M:%S')] ⚠️ patch${i}.tar.gz поврежден (размер: $(numfmt --to=iec $size 2>/dev/null || echo "$size байт")), перезагрузка..."
            rm -f "$output"
            rm -f "${DOWNLOAD_DIR}/patch${i}.tar.gz.aria2" 2>/dev/null
        fi
    fi

    echo "[$(date '+%H:%M:%S')] ===== Загрузка patch${i}.tar.gz ====="

    while [ $retry_count -lt $max_retries ]; do
        echo "[$(date '+%H:%M:%S')] Попытка $((retry_count+1))/$max_retries для patch${i}.tar.gz"
        
        # Выбор метода в зависимости от количества SSL ошибок
        if [ $ssl_retry_count -eq 0 ]; then
            # Метод 1: HTTPS с агрессивными таймаутами
            method_used="HTTPS (агрессивный)"
            echo "[$(date '+%H:%M:%S')] Метод: $method_used"
            
            # Убиваем все старые процессы aria2 для этого файла
            pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            sleep 2
            
            timeout 300 aria2c \
                -x 4 \
                -s 4 \
                --continue=true \
                --timeout=30 \
                --connect-timeout=15 \
                --max-tries=2 \
                --retry-wait=5 \
                --check-certificate=false \
                --disable-ipv6=true \
                --async-dns=false \
                --console-log-level=error \
                --summary-interval=1 \
                --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
                --referer="https://www.objects365.org/" \
                "$url" \
                -d "$DOWNLOAD_DIR" \
                -o "patch${i}.tar.gz"
            
            local aria_exit=$?
            
            # Проверяем, не завис ли процесс
            if [ $aria_exit -eq 124 ]; then
                echo "[$(date '+%H:%M:%S')] ⚠️ timeout 300s превышен, принудительное завершение"
                pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            fi
        
        elif [ $ssl_retry_count -eq 1 ]; then
            # Метод 2: HTTP с агрессивными таймаутами
            method_used="HTTP (агрессивный)"
            echo "[$(date '+%H:%M:%S')] Метод: $method_used"
            
            pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            sleep 2
            
            timeout 300 aria2c \
                -x 4 \
                -s 4 \
                --continue=true \
                --timeout=30 \
                --connect-timeout=15 \
                --max-tries=2 \
                --retry-wait=5 \
                --disable-ipv6=true \
                --async-dns=false \
                --console-log-level=error \
                --summary-interval=1 \
                --user-agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" \
                --referer="https://www.objects365.org/" \
                "$http_url" \
                -d "$DOWNLOAD_DIR" \
                -o "patch${i}.tar.gz"
            
            local aria_exit=$?
            
            if [ $aria_exit -eq 124 ]; then
                echo "[$(date '+%H:%M:%S')] ⚠️ timeout 300s превышен"
                pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            fi
        
        elif [ $ssl_retry_count -eq 2 ]; then
            # Метод 3: curl с короткими таймаутами
            method_used="curl"
            echo "[$(date '+%H:%M:%S')] Метод: $method_used"
            
            pkill -f "curl.*patch${i}\.tar\.gz" 2>/dev/null
            sleep 2
            
            timeout 300 curl -L \
                --insecure \
                --retry 2 \
                --retry-delay 5 \
                --connect-timeout 30 \
                --max-time 300 \
                -C - \
                -A "Mozilla/5.0" \
                -o "$output" \
                "$url" 2>/dev/null
            
            local curl_exit=$?
            
            if [ $curl_exit -eq 0 ] && [ -f "$output" ]; then
                local size=$(stat -c%s "$output" 2>/dev/null || echo 0)
                if [ $size -gt 3000000000 ]; then
                    echo "[$(date '+%H:%M:%S')] ✅ patch${i}.tar.gz загружен через curl"
                    return 0
                fi
            fi
            retry_count=$((retry_count + 1))
            ssl_retry_count=$((ssl_retry_count + 1))
            continue
        
        elif [ $ssl_retry_count -eq 3 ]; then
            # Метод 4: wget с короткими таймаутами
            method_used="wget"
            echo "[$(date '+%H:%M:%S')] Метод: $method_used"
            
            pkill -f "wget.*patch${i}\.tar\.gz" 2>/dev/null
            sleep 2
            
            timeout 300 wget \
                --no-check-certificate \
                --timeout=30 \
                --tries=2 \
                --retry-connrefused \
                --waitretry=5 \
                --user-agent="Mozilla/5.0" \
                --referer="https://www.objects365.org/" \
                -c \
                -O "$output" \
                "$url" 2>/dev/null
            
            local wget_exit=$?
            
            if [ $wget_exit -eq 0 ] && [ -f "$output" ]; then
                local size=$(stat -c%s "$output" 2>/dev/null || echo 0)
                if [ $size -gt 3000000000 ]; then
                    echo "[$(date '+%H:%M:%S')] ✅ patch${i}.tar.gz загружен через wget"
                    return 0
                fi
            fi
            retry_count=$((retry_count + 1))
            ssl_retry_count=$((ssl_retry_count + 1))
            continue
        else
            # Метод 5: aria2c с минимальными параметрами и HTTP
            method_used="aria2c (минимальный HTTP)"
            echo "[$(date '+%H:%M:%S')] Метод: $method_used"
            
            pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            sleep 2
            
            timeout 300 aria2c \
                -x 2 \
                -s 2 \
                --continue=true \
                --timeout=20 \
                --connect-timeout=10 \
                --max-tries=1 \
                --retry-wait=2 \
                "$http_url" \
                -d "$DOWNLOAD_DIR" \
                -o "patch${i}.tar.gz"
            
            local aria_exit=$?
            
            if [ $aria_exit -eq 124 ]; then
                echo "[$(date '+%H:%M:%S')] ⚠️ timeout 300s превышен"
                pkill -f "aria2c.*patch${i}\.tar\.gz" 2>/dev/null
            fi
        fi

        # Проверяем результат
        if [ -f "$output" ]; then 
            local size=$(stat -c%s "$output" 2>/dev/null || echo 0)
            if [ $size -gt 3000000000 ]; then
                echo "[$(date '+%H:%M:%S')] ✅ patch${i}.tar.gz загружен ($(numfmt --to=iec $size))"
                echo "$(date): patch${i}.tar.gz успешно загружен, размер: $size" >> "$LOG_FILE"
                return 0
            elif [ $size -gt 0 ]; then
                echo "[$(date '+%H:%M:%S')] ⚠️ patch${i}.tar.gz частично загружен: $(numfmt --to=iec $size)"
                # Не удаляем, продолжаем докачку
            else
                echo "[$(date '+%H:%M:%S')] ❌ Файл пуст"
                rm -f "$output"
                rm -f "${DOWNLOAD_DIR}/patch${i}.tar.gz.aria2" 2>/dev/null
            fi
        else
            echo "[$(date '+%H:%M:%S')] ❌ Файл не создан"
        fi
        
        # Увеличиваем счетчики
        if [ $ssl_retry_count -lt 5 ]; then
            ssl_retry_count=$((ssl_retry_count + 1))
        fi
        retry_count=$((retry_count + 1))
        
        if [ $retry_count -lt $max_retries ]; then
            local wait_time=10
            echo "[$(date '+%H:%M:%S')] ⏳ Ожидание ${wait_time}с перед повторной попыткой $((retry_count+1))/$max_retries..."
            sleep $wait_time
        fi
    done
    
    echo "[$(date '+%H:%M:%S')] ❌ Не удалось загрузить patch${i}.tar.gz после всех попыток"
    echo "$(date): ОШИБКА загрузки patch${i}.tar.gz" >> "$LOG_FILE"
    return 1
}

export -f download_patch
export DOWNLOAD_DIR
export LOG_FILE

echo "========================================="
echo "Загрузка Objects365 датасета (51 архив)"
echo "========================================="
echo "Директория: $DOWNLOAD_DIR"
echo "Архивы: patch0.tar.gz - patch50.tar.gz"
echo "Метод: Агрессивные таймауты + принудительный сброс"
echo "Лог: $LOG_FILE"
echo "========================================="

# Определяем, какие файлы уже загружены
MISSING_FILES=()
EXISTING_FILES=()

echo "[$(date '+%H:%M:%S')] Проверка существующих файлов..."

for i in $(seq $START $END); do
    if [ -f "$DOWNLOAD_DIR/patch${i}.tar.gz" ]; then
        size=$(stat -c%s "$DOWNLOAD_DIR/patch${i}.tar.gz" 2>/dev/null || echo 0)
        if [ $size -gt 3000000000 ]; then
            EXISTING_FILES+=($i)
            echo "[$(date '+%H:%M:%S')] ✅ patch${i}.tar.gz в порядке ($(numfmt --to=iec $size 2>/dev/null || echo "$size байт"))"
        else
            echo "[$(date '+%H:%M:%S')] ⚠️ patch${i}.tar.gz поврежден (размер: $(numfmt --to=iec $size 2>/dev/null || echo "$size байт"))"
            MISSING_FILES+=($i)
        fi
    else
        MISSING_FILES+=($i)
    fi
done

echo "========================================="
echo "Уже загружено корректно: ${#EXISTING_FILES[@]} архивов"
echo "Требуется загрузить: ${#MISSING_FILES[@]} архивов"
echo "========================================="

if [ ${#MISSING_FILES[@]} -eq 0 ]; then
    echo "✅ Все архивы уже загружены!"
    exit 0
fi

echo "Начинаем загрузку ${#MISSING_FILES[@]} архивов..."
echo "Загружаем ПО ОДНОМУ файлу"
echo "========================================="

# Загружаем по одному файлу
counter=1
for i in "${MISSING_FILES[@]}"; do
    echo "========================================="
    echo "Загрузка файла $counter/${#MISSING_FILES[@]}: patch${i}.tar.gz"
    echo "========================================="
    
    download_patch $i
    
    echo "[$(date '+%H:%M:%S')] Пауза 5 секунд..."
    sleep 5
    
    counter=$((counter + 1))
done

# Финальная проверка
echo "========================================="
echo "Загрузка завершена!"
echo "========================================="

TOTAL_CORRECT=0
TOTAL_FAILED=0

echo "Проверка всех файлов:"
for i in $(seq $START $END); do
    if [ -f "$DOWNLOAD_DIR/patch${i}.tar.gz" ]; then
        size=$(stat -c%s "$DOWNLOAD_DIR/patch${i}.tar.gz" 2>/dev/null || echo 0)
        if [ $size -gt 3000000000 ]; then
            echo "✅ patch${i}.tar.gz: $(numfmt --to=iec $size 2>/dev/null || echo "$size байт")"
            TOTAL_CORRECT=$((TOTAL_CORRECT + 1))
        else
            echo "❌ patch${i}.tar.gz: поврежден - $(numfmt --to=iec $size 2>/dev/null || echo "$size байт")"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
    else
        echo "❌ patch${i}.tar.gz: отсутствует"
        TOTAL_FAILED=$((TOTAL_FAILED + 1))
    fi
done

echo "========================================="
echo "Итог: ✅ $TOTAL_CORRECT из 51, ❌ $TOTAL_FAILED из 51"
echo "Лог сохранен в: $LOG_FILE"
