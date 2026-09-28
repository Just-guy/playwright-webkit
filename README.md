# Playwright WebKit — проверка сайта «как в Safari»

Ручной просмотр сайта в **Playwright WebKit** (движок, используемый Safari) из WSL с отображением окна на рабочем столе Windows через WSLg.

Репозиторий: https://github.com/Just-guy/playwright-webkit.git

## Требования

- WSL2 + **WSLg**
- **Node.js и npm** (обязательно; удобно через [nvm](https://github.com/nvm-sh/nvm))
- `sudo` только внутри `setup.sh` для системных библиотек WebKit — **не** запускайте `sudo ./setup.sh`

```bash
node -v && npm -v
echo $DISPLAY   # обычно :0
```

## Установка

```bash
mkdir -p ~/tools
git clone https://github.com/Just-guy/playwright-webkit.git ~/tools/playwright-webkit
cd ~/tools/playwright-webkit

npm install
npx playwright install webkit

chmod +x setup.sh pw-open   # если после clone нет права на исполнение
./setup.sh                  # от обычного пользователя, НЕ sudo ./setup.sh
```

`setup.sh` **не** ставит Node/npm и **не** вызывает `npm install`. Он:

1. проверяет, что Node/npm и `node_modules/playwright` уже есть;
2. ставит системные зависимости (`playwright install-deps webkit`, тут спросит `sudo`);
3. делает symlink `~/.local/bin/pw-open` → этот каталог (и сам выставляет `chmod +x` скриптам).

Если команда `pw-open` не находится:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Если `./setup.sh` → `Permission denied`:

```bash
chmod +x setup.sh pw-open
./setup.sh
```

Обновление:

```bash
cd ~/tools/playwright-webkit
git pull
npm install
npx playwright install webkit
```

## Использование

URL и устройство **обязательны**:

```bash
pw-open http://localhost/ "iPhone 13"
pw-open https://example.com/ "iPhone 17"
```

Или через env:

```bash
SITE_URL=http://localhost/ DEVICE="iPhone 14" pw-open
```

| Переменная | По умолчанию | Назначение |
|------------|--------------|------------|
| `DPR` | `1` | Device Pixel Ratio (`3` на реальном iPhone; через WSLg сильно тормозит) |
| `PAUSE` | выкл. | `PAUSE=1` — Playwright Inspector |

Список устройств:

```bash
cd ~/tools/playwright-webkit
node -e "import('playwright').then(m=>console.log(Object.keys(m.devices).filter(k=>/iPhone|iPad/.test(k)).join('\n')))"
```

Закрытие: крестик окна или `Ctrl+C`.

## Нюансы WSL

- **Белый экран:** в `open.mjs` задано `GDK_BACKEND=x11` (Wayland в WSLg часто не отображает страницу).
- **Лаги:** для ручного просмотра оставляйте `DPR=1`.
- Это WebKit Playwright, а не полноценный Safari iOS.

## Файлы

| Файл | Назначение |
|------|------------|
| `setup.sh` | Системные deps + symlink `pw-open` |
| `pw-open` | Обёртка для запуска из любой точки WSL |
| `open.mjs` | Запуск WebKit |
| `package.json` | Зависимость `playwright` |
