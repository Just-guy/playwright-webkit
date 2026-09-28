#!/usr/bin/env bash
# Системные зависимости WebKit + команда pw-open в PATH.
# Node.js/npm и пакеты проекта — вручную (см. README.md).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! command -v node >/dev/null || ! command -v npm >/dev/null; then
	echo "Нужны Node.js и npm (обязательная зависимость)." >&2
	echo "Установите, например через nvm: https://github.com/nvm-sh/nvm" >&2
	echo "Затем в этом каталоге:" >&2
	echo "  npm install" >&2
	echo "  npx playwright install webkit" >&2
	exit 1
fi

if [[ ! -d "$ROOT/node_modules/playwright" ]]; then
	echo "Сначала установите npm-зависимости и браузер WebKit:" >&2
	echo "  cd \"$ROOT\"" >&2
	echo "  npm install" >&2
	echo "  npx playwright install webkit" >&2
	echo "После этого снова запустите: $ROOT/setup.sh" >&2
	exit 1
fi

echo "==> системные зависимости WebKit (нужен sudo)"
echo "    Если спросит пароль — введите."
if ! sudo env "PATH=$PATH" npx playwright install-deps webkit; then
	echo "Не удалось поставить deps автоматически. Вручную:" >&2
	echo "  cd \"$ROOT\" && sudo env \"PATH=\$PATH\" npx playwright install-deps webkit" >&2
fi

LINK_DIR="${HOME}/.local/bin"
mkdir -p "$LINK_DIR"
ln -sfn "$ROOT/pw-open" "$LINK_DIR/pw-open"
chmod +x "$ROOT/pw-open" "$ROOT/setup.sh"

case ":$PATH:" in
	*":$LINK_DIR:"*) ;;
	*)
		echo
		echo "Добавьте в ~/.bashrc (если ещё нет):"
		echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
		echo "Затем: source ~/.bashrc"
		;;
esac

echo
echo "Готово. Из любой точки WSL (url и device обязательны):"
echo "  pw-open http://localhost/ \"iPhone 13\""
echo "  SITE_URL=https://example.com/ DEVICE='iPhone 14' pw-open"
echo
echo "Опционально: DPR (по умолчанию 1), PAUSE=1"
