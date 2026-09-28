# Playwright WebKit — проверка сайта «как в Safari»

Локальный инструмент для ручного просмотра сайта в **Playwright WebKit** (движок ≈ Safari) из WSL с окном на рабочем столе Windows (WSLg).

## Требования

- WSL2 + **WSLg** (окно Linux-приложений на Windows)
- **Node.js и npm** — обязательная зависимость (удобно через [nvm](https://github.com/nvm-sh/nvm)). Без них утилита не ставится и не запускается.
- `sudo` для системных библиотек WebKit (один раз)

Проверка Node/npm:

```bash
node -v
npm -v
```

Проверка WSLg: `echo $DISPLAY` → обычно `:0`. Демо: `sudo apt install -y x11-apps && xeyes`.

## Установка (один раз после клона)

### 1. npm-зависимости и браузер WebKit

```bash
cd tools/playwright-webkit
npm install
npx playwright install webkit
```

### 2. Системные libs + команда в PATH

```bash
./setup.sh
```

`setup.sh` **не** ставит Node/npm и **не** вызывает `npm install`. Он только:

1. проверяет, что Node/npm и `node_modules/playwright` уже есть;
2. ставит системные зависимости (`playwright install-deps webkit`);
3. делает symlink `~/.local/bin/pw-open` → этот каталог.

Если `pw-open` не находится:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Повторно только системные deps (nvm + sudo):

```bash
cd tools/playwright-webkit
sudo env "PATH=$PATH" npx playwright install-deps webkit
```

## Использование

URL и устройство **обязательны** (дефолтов нет).

```bash
pw-open http://localhost/ "iPhone 13"
pw-open https://docker.espclubmoscu.com/ "iPhone 17"
```

Через переменные окружения:

```bash
SITE_URL=http://localhost/ DEVICE="iPhone 14" pw-open
```

Опционально:

| Переменная | По умолчанию | Назначение |
|------------|--------------|------------|
| `DPR` | `1` | Device Pixel Ratio. У реального iPhone часто `3`, через WSLg сильно тормозит |
| `PAUSE` | выкл. | `PAUSE=1` — открыть Playwright Inspector |

Примеры:

```bash
DPR=2 pw-open http://localhost/ "iPhone 13"
PAUSE=1 pw-open http://localhost/ "iPhone 13"
```

Список устройств Playwright (iPhone/iPad):

```bash
cd tools/playwright-webkit
node -e "import('playwright').then(m=>console.log(Object.keys(m.devices).filter(k=>/iPhone|iPad/.test(k)).join('\n')))"
```

Закрытие: крестик окна браузера или `Ctrl+C` в терминале.

## Что коммитить в git

**Класть в репозиторий:**

```
tools/playwright-webkit/
  open.mjs
  pw-open
  setup.sh
  package.json
  package-lock.json
  README.md
  .gitignore
```

**Не коммитить:**

- `node_modules/` — ставится через `npm install` (не коммитить)
- кэш браузеров Playwright (`~/.cache/ms-playwright`) — скачивается через `npx playwright install webkit`
- старый домашний каталог `~/playwright-check` (если остался) — не часть репо

В корневом `.gitignore` уже есть `node_modules`; в этой папке лежит дополнительный `.gitignore`.

## Известные нюансы (WSL)

- **Белый экран в окне:** WebKit + Wayland в WSLg часто не рисует страницу. В `open.mjs` задано `GDK_BACKEND=x11`.
- **Лаги:** не ставьте `DPR=3` без нужды; для ручного просмотра достаточно `1`.
- Это **не Safari iOS** целиком, а WebKit Playwright (ближе к Safari, чем Chrome DevTools).

## Файлы

| Файл | Назначение |
|------|------------|
| `setup.sh` | Системные deps WebKit + symlink `pw-open` (без npm install) |
| `pw-open` | Обёртка: из любой точки WSL |
| `open.mjs` | Запуск WebKit и открытие URL |
| `package.json` | Зависимость `playwright` |
