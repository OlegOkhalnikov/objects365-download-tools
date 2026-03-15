#!/bin/bash
# Objects365 Download Tools - ITLAN (c) 2026
# MIT License - see LICENSE.md for details

DOWNLOAD_DIR="object365/images/train"
LOG_FILE="integrity_check.log"

echo "========================================="
echo "ПРОВЕРКА ЦЕЛОСТНОСТИ АРХИВОВ OBJECTS365"
echo "========================================="
echo "Директория: $DOWNLOAD_DIR"
echo "Архивы: patch0.tar.gz - patch50.tar.gz"
echo "========================================="
echo ""

# Очищаем лог
> "$LOG_FILE"

# Счетчики
TOTAL=0
GOOD=0
BAD=0
MISSING=0

# Проверяем 51 архив
for i in {0..50}; do
    FILE="$DOWNLOAD_DIR/patch${i}.tar.gz"
    TOTAL=$((TOTAL + 1))
    
    if [ ! -f "$FILE" ]; then
        echo "❌ patch${i}.tar.gz - ФАЙЛ ОТСУТСТВУЕТ"
        echo "patch${i}.tar.gz - MISSING" >> "$LOG_FILE"
        MISSING=$((MISSING + 1))
        continue
    fi
    
    # Проверка целостности tar.gz
    if tar tzf "$FILE" &>/dev/null; then
        echo "✅ patch${i}.tar.gz - ЦЕЛ"
        echo "patch${i}.tar.gz - GOOD" >> "$LOG_FILE"
        GOOD=$((GOOD + 1))
    else
        echo "❌ patch${i}.tar.gz - БИТЫЙ"
        echo "patch${i}.tar.gz - BAD" >> "$LOG_FILE"
        BAD=$((BAD + 1))
    fi
done

echo ""
echo "========================================="
echo "РЕЗУЛЬТАТЫ ПРОВЕРКИ"
echo "========================================="
echo "✅ Целых: $GOOD"
echo "❌ Битых: $BAD"
echo "❌ Отсутствует: $MISSING"
echo "📊 Всего проверено: $TOTAL"
echo "========================================="
echo "Лог сохранен в: $LOG_FILE"

# Если есть битые файлы, показываем их список
if [ $BAD -gt 0 ]; then
    echo ""
    echo "Битые архивы:"
    for i in {0..50}; do
        FILE="$DOWNLOAD_DIR/patch${i}.tar.gz"
        if [ -f "$FILE" ] && ! tar tzf "$FILE" &>/dev/null; then
            echo "  patch${i}.tar.gz"
        fi
    done
fi

# Если есть отсутствующие файлы, показываем их список
if [ $MISSING -gt 0 ]; then
    echo ""
    echo "Отсутствующие архивы:"
    for i in {0..50}; do
        if [ ! -f "$DOWNLOAD_DIR/patch${i}.tar.gz" ]; then
            echo "  patch${i}.tar.gz"
        fi
    done
fi
