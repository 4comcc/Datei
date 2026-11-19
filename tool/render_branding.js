// Renders branding SVGs to every PNG the Android/web app needs.
// Usage (from repo root): node tool/render_branding.js
const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const B = (f) => path.join(root, 'assets/branding', f);
const RES = path.join(root, 'android/app/src/main/res');
const svg = (f) => fs.readFileSync(B(f), 'utf8');
const font = (w) =>
  'data:font/ttf;base64,' + fs.readFileSync(path.join(root, `assets/fonts/IBMPlexSansArabic-${w}.ttf`)).toString('base64');

const densities = { mdpi: 1, hdpi: 1.5, xhdpi: 2, xxhdpi: 3, xxxhdpi: 4 };

async function render(page, html, size, out, { width = size, height = size } = {}) {
  await page.setViewportSize({ width, height });
  await page.setContent(
    `<html><head><style>@font-face{font-family:"IBM Plex Sans Arabic";font-weight:700;src:url(${font('Bold')})}
     html,body{margin:0;background:transparent}svg{display:block;width:${width}px;height:${height}px}</style></head>
     <body>${html}</body></html>`,
  );
  await page.evaluate(() => document.fonts.ready);
  fs.mkdirSync(path.dirname(out), { recursive: true });
  await page.screenshot({ path: out, omitBackground: true });
}

(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ deviceScaleFactor: 1 });
  const icon = svg('datei_icon.svg');
  const fg = svg('datei_icon_foreground.svg');
  const mono = svg('datei_icon_monochrome.svg');

  for (const [d, s] of Object.entries(densities)) {
    await render(page, icon, 48 * s, `${RES}/mipmap-${d}/ic_launcher.png`);
    await render(page, fg, 108 * s, `${RES}/mipmap-${d}/ic_launcher_foreground.png`);
    await render(page, mono, 108 * s, `${RES}/mipmap-${d}/ic_launcher_monochrome.png`);
    // Android 12+ splash icon: 288 dp canvas, shown inside a 192 dp circle.
    await render(page, fg, 288 * s, `${RES}/drawable-${d}/splash_icon.png`);
    // Android < 12 launch screen: rounded-square icon, 128 dp.
    await render(page, icon, 128 * s, `${RES}/drawable-${d}/launch_image.png`);
  }

  const png = (f) => B(path.join('png', f));
  await render(page, icon, 1024, png('datei_icon_1024.png'));
  await render(page, svg('datei_icon_square.svg'), 512, png('play_store_icon_512.png'));
  const wm = svg('datei_wordmark.svg');
  await render(page, wm, 0, png('datei_wordmark.png'), { width: 1120, height: 312 });
  await render(page, wm.replaceAll('#596B35', '#F4F1E7'), 0, png('datei_wordmark_on_dark.png'), { width: 1120, height: 312 });

  for (const [n, s] of [['Icon-192', 192], ['Icon-512', 512], ['Icon-maskable-192', 192], ['Icon-maskable-512', 512]]) {
    await render(page, n.includes('maskable') ? svg('datei_icon_square.svg') : icon, s, path.join(root, `web/icons/${n}.png`));
  }
  await render(page, icon, 32, path.join(root, 'web/favicon.png'));
  await browser.close();
  console.log('branding rendered');
})();
