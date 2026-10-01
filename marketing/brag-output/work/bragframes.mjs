import { chromium } from '/opt/node-tools/node_modules/playwright/index.mjs';
const [,, out, file, list] = process.argv;
const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1920, height: 1080 } });
await page.goto('file://' + file);
await page.evaluate(() => document.fonts.ready);
await page.waitForTimeout(400);
const fps = 30;
const times = list ? list.split(',').map(Number) : Array.from({ length: 21 * fps }, (_, i) => i / fps);
let i = 0;
for (const t of times) {
  await page.evaluate((t) => window.renderAt(t), t);
  await page.screenshot({ path: `${out}/${list ? 's' + t : 'f' + String(i).padStart(4, '0')}.jpg`, type: 'jpeg', quality: 92 });
  i++;
}
await browser.close();
