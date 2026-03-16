# Полезные команды 🧑‍💻

## 📦 Скачивание архивов с локального WEB-сервера

### Linux / macOS / WSL

#### Вариант 1: wget
```bash
# Простой цикл с wget
for i in {0..50}; do
    echo "📥 Скачивание patch${i}.tar.gz..."
    wget "http://IP:port/images/train/patch${i}.tar.gz"
    sleep 1
done
```

#### Вариант 2: curl
```bash
# curl с прогресс-баром
for i in {0..50}; do
    echo "📥 Скачивание patch${i}.tar.gz..."
    curl -# -O "http://IP:port/images/train/patch${i}.tar.gz"
done
```

#### Вариант 3: параллельная загрузка (быстрее!)
```bash
# Установите parallel: sudo apt install parallel (Ubuntu/Debian)
# или brew install parallel (macOS)
# j 10 - десять потоков

seq 0 50 | parallel -j 10 "curl -# -O http://IP:port/images/train/patch{}.tar.gz"
```

### Windows (без WSL)

#### PowerShell (встроен в Windows 10/11)
```powershell
# Простая загрузка
0..50 | % { Write-Host "patch$_.tar.gz"; Invoke-WebRequest "http://IP:port/images/train/patch$_.tar.gz" -OutFile "patch$_.tar.gz" }
```
или 
```powershell
# Создает папку extracted, скачивает и распаковывает все архивы
md extracted -Force; 0..50 | % { $f="patch$_.tar.gz"; Write-Host $f; Invoke-WebRequest "http://IP:port/images/train/$f" -OutFile $f; tar -xzf $f -C extracted }
```

- 📁 Создает папку extracted (или перезаписывает если существует)
- 🔄 Проходит по индексам от 0 до 50
- 📥 Скачивает каждый архив с отображением имени
- 📦 Автоматически распаковывает в папку extracted

## 📂 Распаковка архивов

### Linux / macOS

#### Последовательная распаковка
```bash
# Распаковать все .tar.gz в текущей папке
for f in patch*.tar.gz; do
    tar -xzf "$f" && echo "✅ $f OK" || echo "❌ $f ERROR"
done
```

#### Параллельная распаковка (рекомендуется)
```bash
# Установите parallel: sudo apt install parallel (Ubuntu/Debian)
# или brew install parallel (macOS)

# Распаковка в 4 потока
parallel -j 4 'tar -xzf {} && echo "✅ {} OK" || echo "❌ {} ERROR"' ::: patch{0..50}.tar.gz

# Распаковка в 10 потоков (если много ядер)
parallel -j 4 'tar -xzf {} && echo "✅ {} OK" || echo "❌ {} ERROR"' ::: patch{0..50}.tar.gz
```

#### Распаковка с перемещением в отдельную папку
```bash
# Создать папку и распаковать туда все архивы
mkdir -p extracted
parallel -j 4 'tar -xzf {} -C extracted && echo "✅ {} OK"' ::: patch{0..50}.tar.gz
```

### Windows

#### PowerShell
```powershell
# Простая распаковка всех .tar.gz архивов
Get-ChildItem *.tar.gz | % { $n=$_.Name; tar -xzf $n; Write-Host "$(if ($?) {'✅'} else {'❌'}) $n" }
```
или
```powershell
# Распаковка в папку
md extracted -Force; Get-ChildItem *.tar.gz | % { tar -xzf $_.Name -C extracted; Write-Host "$(if ($?) {'✅'} else {'❌'}) $($_.Name)" }
```

#### PowerShell с параллельной распаковкой
```powershell
Get-ChildItem *.tar.gz | % -Parallel { tar -xzf $_.Name; Write-Host "$(if ($?) {'✅'} else {'❌'}) $($_.Name)" } -ThrottleLimit 4```
```

## 🔄 Полный цикл: скачивание + распаковка

### Linux / macOS (одной строкой)
```bash
# Скачать и распаковать все архивы
for i in {0..50}; do curl -# -O "http://IP:port/images/train/patch$i.tar.gz" && tar -xzf "patch$i.tar.gz" & done; wait
```

### Windows PowerShell
```powershell
# Скачать и распаковать (последовательно)
0..50 | % { $f="patch$_.tar.gz"; Write-Host "📥 $f"; Invoke-WebRequest "http://IP:port/images/train/$f" -OutFile $f; tar -xzf $f }
```
### Windows PowerShell c проверкой успешности:
```powershell
0..50 | % { $f="patch$_.tar.gz"; Write-Host "📥 $f"; Invoke-WebRequest "http://IP:port/images/train/$f" -OutFile $f; tar -xzf $f; Write-Host "$(if ($?) {'✅'} else {'❌'}) $f" }
```

## 📊 Проверка загруженных файлов

### Linux / macOS
```bash
# Проверить размеры всех файлов
ls -la patch*.tar.gz

# Проверить количество
ls patch*.tar.gz | wc -l

# Проверить целостность архивов
for f in patch*.tar.gz; do
    tar -tzf "$f" > /dev/null 2>&1 && echo "✅ $f" || echo "❌ $f поврежден"
done
```

### Windows PowerShell
```powershell
# Проверить размеры
Get-ChildItem patch*.tar.gz | Select-Object Name, @{Name="Size(MB)";Expression={[math]::Round($_.Length/1MB, 2)}}

# Проверить количество
(Get-ChildItem patch*.tar.gz).Count

# Проверить целостность
Get-ChildItem *.tar.gz | ForEach-Object {
    $result = tar -tzf $_.Name 2>$null
    if ($?) { Write-Host "✅ $($_.Name)" -ForegroundColor Green }
    else { Write-Host "❌ $($_.Name) поврежден" -ForegroundColor Red }
}
```

## 🛠️ Полезные советы

### Установка необходимых инструментов

**Ubuntu/Debian:**
```bash
sudo apt update
sudo apt install curl wget parallel
```

**macOS:**
```bash
brew install curl wget parallel
```

**Windows:**

Установите Chocolatey (если не установлен). Запустите PowerShell от имени администратора и выполните команду:
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```
```powershell
# Установить: curl wget 7zip
choco install curl wget 7zip

# Или скачайте вручную:
# curl: https://curl.se/windows/
# wget: https://eternallybored.org/misc/wget/
# 7-Zip: https://www.7-zip.org/
```

### Проверка наличия инструментов
```bash
# Linux/macOS
which curl wget parallel
```

```powershell
# Windows
Get-Command curl, wget, tar -ErrorAction SilentlyContinue
```

---

## 📌 Примечания

- Всего **51 архив** (patch0.tar.gz - patch50.tar.gz)
- Размер каждого архива: ~**3.2-8.9 G**
- Общий размер: ~**327 ГБ GB**
- Убедитесь, что у вас достаточно места на диске.

---

**ITLAN © 2026** | [Основная документация](README.md) | [Лицензия](LICENSE.md)
