# check_targz.sh - Скрипт проверки целостности архивов

## 📋 Описание
Скрипт для проверки целостности скачанных архивов датасета Objects365 (patch0.tar.gz - patch50.tar.gz). Проверяет наличие файлов и их целостность как tar.gz архивов.

## 🔧 Параметры
- `DOWNLOAD_DIR="object365/images/train"` - директория с архивами
- `LOG_FILE="integrity_check.log"` - файл для сохранения результатов

## 📊 Что проверяет
- **51 архив** с именами `patch0.tar.gz` - `patch50.tar.gz`
- Наличие каждого файла
- Целостность структуры tar.gz архива

## 🚀 Использование
```bash
chmod +x check_targz.sh
./check_targz.sh
```

## 📈 Вывод
- **Интерактивный вывод** в консоль с статусами
- **Лог-файл** `integrity_check.log` с краткими записями
- **Итоговая статистика**: целые / битые / отсутствующие
- **Списки проблемных файлов** (если есть)

## 🎯 Статусы
- ✅ **GOOD** - архив цел
- ❌ **BAD** - архив поврежден
- ❌ **MISSING** - файл отсутствует

## 📝 Пример лога
```
patch0.tar.gz - GOOD
patch1.tar.gz - GOOD
patch2.tar.gz - BAD
patch3.tar.gz - MISSING
```
---
*© 2026 ITLAN. Licensed under MIT - see [LICENSE.md](LICENSE.md)*
