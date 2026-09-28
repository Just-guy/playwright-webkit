import { webkit, devices } from 'playwright';

// Обязательно: SITE_URL и DEVICE (или аргументы pw-open)
const url = process.env.SITE_URL;
const deviceName = process.env.DEVICE;
// Реальный iPhone = DPR 3 → через WSLg люто тормозит. Для ручного просмотра хватает 1.
const dpr = Number(process.env.DPR || 1);
const pause = process.env.PAUSE === '1';

if (!url || !deviceName) {
	console.error('Нужны URL и устройство.');
	console.error('  pw-open <url> <device>');
	console.error('  SITE_URL=… DEVICE=… pw-open');
	console.error('Пример: pw-open http://localhost/ "iPhone 13"');
	process.exit(1);
}

const device = devices[deviceName];
if (!device) {
	console.error('Неизвестное устройство:', deviceName);
	console.error('Список: node -e "import(\'playwright\').then(m=>console.log(Object.keys(m.devices).filter(k=>/iPhone|iPad/.test(k)).join(\'\\n\')))"');
	process.exit(1);
}

// WSLg: WebKit через Wayland часто даёт белый экран — нужен X11.
const browser = await webkit.launch({
	headless: false,
	env: {
		...process.env,
		GDK_BACKEND: 'x11',
	},
});
const context = await browser.newContext({
	...device,
	deviceScaleFactor: dpr,
	ignoreHTTPSErrors: true,
});
const page = await context.newPage();
await page.goto(url, { waitUntil: 'domcontentloaded' });

console.log('Открыто:', url);
console.log('Устройство:', deviceName, `| DPR: ${dpr}`);
console.log(pause ? 'PAUSE=1: Resume в инспекторе или закройте окно.' : 'Закройте окно браузера (или Ctrl+C).');

if (pause) {
	await page.pause();
} else {
	await new Promise((resolve) => browser.on('disconnected', resolve));
}
await browser.close().catch(() => {});
