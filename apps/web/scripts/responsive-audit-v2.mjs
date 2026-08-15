import { chromium } from 'playwright'
import { writeFileSync } from 'node:fs'

const BASE = 'http://localhost:5173'
const breakpoints = [
  { w: 320, h: 568, label: '320' },
  { w: 375, h: 667, label: '375' },
  { w: 390, h: 844, label: '390' },
  { w: 414, h: 896, label: '414' },
  { w: 768, h: 1024, label: '768' },
  { w: 834, h: 1194, label: '834' },
  { w: 1024, h: 768, label: '1024' },
  { w: 1280, h: 800, label: '1280' },
  { w: 1440, h: 900, label: '1440' },
  { w: 1920, h: 1080, label: '1920' },
]

const pages = [
  { path: '/', name: 'Home', wait: '#compare' },
  { path: '/privacy', name: 'Privacy', wait: 'h1' },
  { path: '/terms', name: 'Terms', wait: 'h1' },
  { path: '/refund', name: 'Refund', wait: 'h1' },
  { path: '/cancellation', name: 'Cancellation', wait: 'h1' },
  { path: '/contact', name: 'Contact', wait: 'h1' },
  { path: '/account-deletion', name: 'Account Deletion', wait: 'h1' },
  { path: '/join/demo-token', name: 'Join Group', wait: 'h1' },
  { path: '/invite/friend/demo-user', name: 'Friend Invite', wait: 'h1' },
  { path: '/app', name: 'App Login', wait: 'h1' },
  { path: '/does-not-exist', name: '404', wait: 'h1' },
]

const auditFn = `(() => {
  const vw = window.innerWidth, vh = window.innerHeight;
  const issues = [];
  const docW = document.documentElement.scrollWidth;
  if (docW > vw + 1) issues.push({ type: 'page-horizontal-overflow', detail: 'doc=' + docW + ' vw=' + vw });

  const visibleOverflow = [];
  for (const el of document.querySelectorAll('body *')) {
    const st = getComputedStyle(el);
    if (st.display === 'none' || st.visibility === 'hidden' || st.opacity === '0') continue;
    if (st.position === 'fixed' && el.id === 'nav-drawer') continue;
    const r = el.getBoundingClientRect();
    if (r.width < 2 || r.height < 2) continue;
    if (r.top > vh || r.bottom < 0) continue;
    if (r.right > vw + 1) {
      const tag = el.tagName.toLowerCase();
      const id = el.id ? '#' + el.id : '';
      visibleOverflow.push({ sel: tag + id, right: Math.round(r.right), vw, overflowPx: Math.round(r.right - vw) });
    }
  }
  if (visibleOverflow.length) issues.push({ type: 'visible-overflow-right', count: visibleOverflow.length, samples: visibleOverflow.slice(0, 8) });

  const small = [];
  for (const el of document.querySelectorAll('a,button,[role=button]')) {
    const st = getComputedStyle(el);
    if (st.display === 'none' || st.visibility === 'hidden') continue;
    const r = el.getBoundingClientRect();
    if (!r.width || !r.height || r.top > vh || r.bottom < 0) continue;
    if (r.width < 44 || r.height < 44) {
      small.push({ text: (el.textContent||el.getAttribute('aria-label')||'').trim().slice(0,40), w: Math.round(r.width), h: Math.round(r.height) });
    }
  }
  if (small.length) issues.push({ type: 'small-touch-target', count: small.length, samples: small.slice(0, 10) });

  const sections = {};
  for (const id of ['hero','compare','pricing','trust','faq','download']) {
    const el = document.getElementById(id);
    if (!el) { sections[id] = { missing: true }; continue; }
    const r = el.getBoundingClientRect();
    sections[id] = { w: Math.round(r.width), right: Math.round(r.right), overflow: r.right > vw + 1 };
  }

  const compareTable = document.querySelector('#compare table');
  let compare = null;
  if (compareTable) {
    const wrap = compareTable.closest('[class]');
    compare = {
      tableMinWidth: getComputedStyle(compareTable).minWidth,
      tableWidth: Math.round(compareTable.getBoundingClientRect().width),
      wrapScrollW: wrap ? wrap.scrollWidth : null,
      wrapClientW: wrap ? wrap.clientWidth : null,
      hasHorizontalScroll: wrap ? wrap.scrollWidth > wrap.clientWidth + 1 : null,
    };
  }

  return { vw, vh, scrollY: window.scrollY, issues, sections, compare };
})()`

async function main() {
  const browser = await chromium.launch({
    headless: true,
    args: ['--use-gl=angle', '--enable-webgl'],
  })
  const page = await browser.newPage()
  const all = []

  for (const p of pages) {
    await page.goto(`${BASE}${p.path}`, { waitUntil: 'domcontentloaded', timeout: 60000 })
    await page.evaluate(() => {
      localStorage.setItem('splitr_intro_seen', '1')
      document.querySelector('button[aria-label="Close"]')?.click()
    })
    try {
      await page.waitForSelector(p.wait, { timeout: 15000 })
    } catch {
      all.push({ page: p.name, path: p.path, error: `selector ${p.wait} not found` })
    }
    await page.waitForTimeout(2000)

    for (const bp of breakpoints) {
      await page.setViewportSize({ width: bp.w, height: bp.h })
      await page.waitForTimeout(600)

      const scrollPts = await page.evaluate(() => {
        const h = document.documentElement.scrollHeight
        const vh = window.innerHeight
        const pts = [0]
        for (let y = vh * 0.6; y < h; y += vh * 0.65) pts.push(Math.floor(y))
        if (h > vh) pts.push(Math.max(0, h - vh))
        return [...new Set(pts)]
      })

      const bpIssues = []
      for (const y of scrollPts) {
        await page.evaluate((yy) => window.scrollTo(0, yy), y)
        await page.waitForTimeout(250)
        const res = await page.evaluate(auditFn)
        if (res.issues.length) bpIssues.push({ scrollY: y, ...res })
      }

      if (bpIssues.length) {
        all.push({ page: p.name, path: p.path, breakpoint: bp.label, viewport: `${bp.w}x${bp.h}`, checks: bpIssues })
      } else {
        const top = await page.evaluate(auditFn)
        all.push({ page: p.name, path: p.path, breakpoint: bp.label, viewport: `${bp.w}x${bp.h}`, ok: true, sections: top.sections, compare: top.compare })
      }
    }
  }

  await browser.close()
  writeFileSync('scripts/responsive-audit-v2.json', JSON.stringify(all, null, 2))
  const problems = all.filter((x) => x.checks || x.error)
  console.log(JSON.stringify({ total: all.length, problems: problems.length, summary: problems.map((p) => ({ page: p.page, bp: p.breakpoint, error: p.error, issueCount: p.checks?.length })) }, null, 2))
}

main()
