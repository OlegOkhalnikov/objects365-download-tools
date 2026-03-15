# 📁 Структура датасета Objects365

## Общая информация
```
$ tree -h --du object365/images
```
```
object365/
├── images/
│   └── train/           # 51 архив, общий вес 327 ГБ
│       ├── patch0.tar.gz   [3.6G]
│       ├── patch1.tar.gz   [3.6G]
│       ├── patch2.tar.gz   [3.6G]
│       ├── patch3.tar.gz   [3.4G]
│       ├── patch4.tar.gz   [3.5G]
│       ├── patch5.tar.gz   [3.4G]
│       ├── patch6.tar.gz   [3.4G]
│       ├── patch7.tar.gz   [3.4G]
│       ├── patch8.tar.gz   [3.4G]
│       ├── patch9.tar.gz   [3.5G]
│       ├── patch10.tar.gz  [3.4G]
│       ├── patch11.tar.gz  [3.5G]
│       ├── patch12.tar.gz  [3.9G]
│       ├── patch13.tar.gz  [3.9G]
│       ├── patch14.tar.gz  [3.9G]
│       ├── patch15.tar.gz  [3.2G]
│       ├── patch16.tar.gz  [7.7G]
│       ├── patch17.tar.gz  [7.6G]
│       ├── patch18.tar.gz  [7.7G]
│       ├── patch19.tar.gz  [7.6G]
│       ├── patch20.tar.gz  [7.8G]
│       ├── patch21.tar.gz  [7.8G]
│       ├── patch22.tar.gz  [7.8G]
│       ├── patch23.tar.gz  [7.8G]
│       ├── patch24.tar.gz  [7.6G]
│       ├── patch25.tar.gz  [7.6G]
│       ├── patch26.tar.gz  [7.5G]
│       ├── patch27.tar.gz  [7.6G]
│       ├── patch28.tar.gz  [7.4G]
│       ├── patch29.tar.gz  [7.8G]
│       ├── patch30.tar.gz  [7.6G]
│       ├── patch31.tar.gz  [7.7G]
│       ├── patch32.tar.gz  [7.7G]
│       ├── patch33.tar.gz  [7.7G]
│       ├── patch34.tar.gz  [7.8G]
│       ├── patch35.tar.gz  [7.7G]
│       ├── patch36.tar.gz  [7.7G]
│       ├── patch37.tar.gz  [7.6G]
│       ├── patch38.tar.gz  [7.7G]
│       ├── patch39.tar.gz  [7.8G]
│       ├── patch40.tar.gz  [7.6G]
│       ├── patch41.tar.gz  [7.7G]
│       ├── patch42.tar.gz  [7.7G]
│       ├── patch43.tar.gz  [7.9G]
│       ├── patch44.tar.gz  [7.9G]
│       ├── patch45.tar.gz  [4.3G]
│       ├── patch46.tar.gz  [8.9G]
│       ├── patch47.tar.gz  [8.2G]
│       ├── patch48.tar.gz  [8.5G]
│       ├── patch49.tar.gz  [8.6G]
│       └── patch50.tar.gz  [8.2G]
└── annotations/         # Аннотации (разметка)
    ├── train.json       # ~10+ млн bounding boxes
    └── val.json         # валидационная выборка
```

## 📊 Статистика

| Категория | Значение |
|-----------|----------|
| **Всего файлов** | 51 |
| **Общий размер** | 327 ГБ |
| **Самый маленький** | `patch15.tar.gz` (3.2G) |
| **Самый большой** | `patch46.tar.gz` (8.9G) |

### Распределение по размеру

| Группа | Размер | Номера архивов |
|--------|--------|-----------------|
| **Маленькие** | 3.2G - 4.3G | 0-15, 45 |
| **Средние** | 7.4G - 7.9G | 16-44 |
| **Крупные** | 8.2G - 8.9G | 46-50 |

## 🗜️ Распаковка архивов

### Распаковать все архивы последовательно
```bash
cd object365/images/train
for i in {0..50}; do
    echo "Распаковка patch${i}.tar.gz..."
    tar -xzf "patch${i}.tar.gz"
    echo "✅ patch${i}.tar.gz распакован"
done
```

### Распаковать конкретный диапазон
```bash
cd object365/images/train
# Например, только маленькие архивы
for i in {0..15} 45; do
    tar -xzf "patch${i}.tar.gz"
done
```

### Использовать параллельную распаковку (быстрее)
```bash
cd object365/images/train
ls patch*.tar.gz | parallel -j 4 'tar -xzf {} && echo "✅ {} распакован"'
```
*Требуется установить `parallel`: `sudo apt install parallel`*

## 📌 Примечания

- После распаковки архивов общий размер датасета увеличится до **~1.5 ТБ**
- Для проверки целостности перед распаковкой используйте `check_targz.sh`
- Для дозагрузки поврежденных файлов используйте `redownload_bad.sh`
- Рекомендуется иметь **минимум 2 ТБ** свободного места перед распаковкой

---
*© 2026 ITLAN. Licensed under MIT - see [LICENSE.md](LICENSE.md)*
