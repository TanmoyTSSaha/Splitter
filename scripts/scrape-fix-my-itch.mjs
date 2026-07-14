import { chromium } from 'playwright';
import { writeFileSync } from 'fs';

const categories = [
  'B2B Services', 'Beauty & Personal Care', 'Consumer Services', 'E-commerce',
  'EdTech', 'FinTech', 'Food & Beverage', 'Home Services', 'Logistics',
  'Payment Issues', 'Real Estate', 'SaaS', 'Transportation', 'Travel',
  'Healthtech', 'Other',
];

function parseProblems(text) {
  const marker = 'ITCH SCORE\n\nINDUSTRY\n\n';
  const start = text.lastIndexOf(marker);
  if (start === -1) return [];
  const chunk = text.slice(start + marker.length);
  const end = Math.min(
    ...['START BUILDING', 'Visit razorpay.com']
      .map((m) => { const i = chunk.indexOf(m); return i > 0 ? i : chunk.length; })
  );
  const lines = chunk.slice(0, end).split('\n').map((l) => l.trim()).filter(Boolean);
  const problems = [];
  for (let i = 0; i < lines.length; i++) {
    if (/^(Why|Where|How|What|When) /.test(lines[i])) {
      const scoreLine = lines[i + 1];
      const industry = lines[i + 2];
      if (scoreLine && !Number.isNaN(parseFloat(scoreLine)) && industry) {
        problems.push({ problem: lines[i], score: parseFloat(scoreLine), industry });
        i += 2;
      }
    }
  }
  return problems;
}

const browser = await chromium.launch({ headless: true });
const page = await browser.newPage();
await page.goto('https://razorpay.com/m/fix-my-itch/#all-problems', { waitUntil: 'networkidle' });
await page.waitForTimeout(3000);

// Scroll to all problems section
await page.locator('text=ALL PROBLEMS').first().scrollIntoViewIfNeeded();
await page.waitForTimeout(1000);

const allResults = [];

for (const cat of categories) {
  const filter = page.locator('p').filter({ hasText: new RegExp(`^${cat.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')}$`) });
  const count = await filter.count();
  let clicked = false;
  for (let i = 0; i < count; i++) {
    const el = filter.nth(i);
    const box = await el.boundingBox();
    if (box && box.width < 250) {
      await el.click();
      clicked = true;
      break;
    }
  }
  if (!clicked && count > 0) await filter.first().click();
  await page.waitForTimeout(2500);
  const text = await page.locator('body').innerText();
  const problems = parseProblems(text);
  allResults.push({ category: cat, count: problems.length, problems });
  console.log(`${cat}: ${problems.length} problems, top=${problems[0]?.score ?? 'n/a'}`);
}

const global = [];
const seen = new Set();
for (const r of allResults) {
  for (const p of r.problems) {
    if (!seen.has(p.problem)) {
      seen.add(p.problem);
      global.push({ ...p, filterCategory: r.category });
    }
  }
}
global.sort((a, b) => b.score - a.score);

const output = { totalUnique: global.length, totalListed: allResults.reduce((s, r) => s + r.count, 0), allResults, global };
writeFileSync('scripts/fix-my-itch-data.json', JSON.stringify(output, null, 2));
console.log('TOTAL UNIQUE:', global.length);
console.log('TOP 15:', global.slice(0, 15).map((p) => `${p.score} [${p.industry}] ${p.problem.slice(0, 60)}...`));

await browser.close();
