# 📥 **download_annotations.sh** — загрузчик аннотаций Objects365

## 📋 Описание

Скрипт для скачивания файлов аннотаций (разметки) датасета Objects365. Использует проверенные ссылки из официального кода YOLOv5.

## 📂 Что скачивается

| Файл | Тип | Размер | Содержимое |
|------|-----|--------|------------|
| `zhiyuan_objv2_train.tar.gz` | Архив | ~1-2 GB | Тренировочные аннотации (после распаковки `zhiyuan_objv2_train.json`) |
| `zhiyuan_objv2_val.json` | JSON | ~200-300 MB | Валидационные аннотации |

После распаковки архива в папке `object365/annotations/` появятся:
- `zhiyuan_objv2_train.json` — тренировочная разметка (~10 млн bounding boxes)
- `zhiyuan_objv2_val.json` — валидационная разметка

## 🚀 Использование

```bash
# Сделать скрипт исполняемым
chmod +x download_annotations.sh

# Запустить загрузку
./download_annotations.sh
# или
bash download_annotations.sh
```

## 🔧 Возможности

- ✅ **Автоматическая распаковка** `tar.gz` архивов
- ✅ **Докачка** при обрыве соединения (`-C -` в curl)
- ✅ **Повторные попытки** при ошибках (до 9 раз)
- ✅ **Прогресс-бар** при загрузке
- ✅ **Проверка размера** загруженных файлов

## 📊 Пример вывода

```
=========================================
📥 Скачивание аннотаций Objects365
=========================================
Директория: object365/annotations
=========================================

📦 Скачивание: zhiyuan_objv2_train.tar.gz
######################################################################## 100.0%
✅ Успешно: zhiyuan_objv2_train.tar.gz (1.2G)
📦 Распаковка zhiyuan_objv2_train.tar.gz...
✅ Распаковано в object365/annotations
total 1.3G
-rw-r--r-- 1 user user 1.2G zhiyuan_objv2_train.tar.gz
-rw-r--r-- 1 user user 1.2G zhiyuan_objv2_train.json

📦 Скачивание: zhiyuan_objv2_val.json
######################################################################## 100.0%
✅ Успешно: zhiyuan_objv2_val.json (245M)

=========================================
📊 Содержимое object365/annotations:
total 1.5G
-rw-r--r-- 1 user user 1.2G zhiyuan_objv2_train.json
-rw-r--r-- 1 user user 1.2G zhiyuan_objv2_train.tar.gz
-rw-r--r-- 1 user user 245M zhiyuan_objv2_val.json
=========================================
```

## 📌 Структура после загрузки

```
object365/
├── annotations/
│   ├── zhiyuan_objv2_train.tar.gz  # архив (можно удалить)
│   ├── zhiyuan_objv2_train.json    # тренировочные аннотации
│   └── zhiyuan_objv2_val.json      # валидационные аннотации
└── images/
    └── train/                       # 51 архив с изображениями
        ├── patch0.tar.gz
        └── ...
```

## 🔍 Проверка аннотаций

```bash
# Посмотреть первые строки JSON
head -20 object365/annotations/zhiyuan_objv2_train.json

# Подсчитать количество аннотаций (если установлен jq)
jq '.annotations | length' object365/annotations/zhiyuan_objv2_train.json
```

## ⚠️ Примечания

- **Train аннотации** поставляются в архиве `tar.gz` (автоматически распаковывается)
- **Val аннотации** — прямой JSON-файл
- После успешной загрузки архив `zhiyuan_objv2_train.tar.gz` можно удалить
- Ссылки взяты из официального репозитория YOLOv5 и проверены на работоспособность

## 📚 Дополнительно

- [Официальный сайт Objects365](https://www.objects365.org/)
- [YOLOv5 с поддержкой Objects365](https://github.com/ultralytics/yolov5)
- [Формат COCO JSON](https://cocodataset.org/#format-data)