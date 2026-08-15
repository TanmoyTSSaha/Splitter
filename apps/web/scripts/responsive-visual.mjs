import { chromium } from 'playwright'
import { mkdir, writeFile } from 'node:fs/promises'
import path from 'node:path'

const BASE = 'http://localhost:5173'
const OUT = path.join('scripts', 'responsive-screenshots')

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

const sections = [
  { name: 'hero', selector: '[aria-label="Split. Track. Settle."]', scroll: 0 },
  { name: 'compare', selector: '#compare, [aria-label="How Splitr compares"]', scroll: null },
  { name: 'pricing', selector: '[aria-label="Splitr Pro"]', scroll: null },
  { name: 'faq', selector: '[aria-label="FAQ"]', scroll: null },
  { name: 'footer', selector: 'footer', scroll: null },
]

async function main() {
  await mkdir(OUT, { recursive: true })
  const browser = await chromium.launch({ headless: true })
  const page = await browser.newPage()

  const report = []

  await page.goto(`${BASE}/`, { waitUntil: 'networkidle' })
  await page.evaluate(() => {
    localStorage.setItem('splitr_intro_seen', '1')
    document.querySelector('button[aria-label="Close"]')?.click()
  })

  for (const bp of breakpoints) {
    await page.setViewportSize({ width: bp.w, height: bp.h })
    await page.waitForTimeout(500)

    const pageMetrics = await page.evaluate(() => ({
      scrollW: document.documentElement.scrollWidth,
      vw: window.innerWidth,
      overflow: document.documentElement.scrollWidth > window.innerWidth + 1,
    }))

    await page.screenshot({
      path: path.join(OUT, `home-top-${bp.label}.png`),
      fullPage: false,
    })

    for (const sec of sections) {
      const el = page.locator(sec.selector).first()
      if ((await el.count()) === 0) {
        report.push({ bp: bp.label, section: sec.name, error: 'selector not found' })
        continue
      }
      await el.scrollIntoViewIfNeeded()
      await page.waitForTimeout(300)
      const box = await el.boundingBox()
      const metrics = await el.evaluate((node) => {
        const r = node.getBoundingClientRect()
        return {
          width: r.width,
          right: r.right,
          vw: window.innerWidth,
          overflow: r.right > window.innerWidth + 1 || r.left < -1,
          scrollW: node.scrollWidth,
          clientW: node.clientWidth,
        }
      })
      await page.screenshot({
        path: path.join(OUT, `home-${sec.name}-${bp.label}.png`),
        fullPage: false,
      })
      report.push({ bp: bp.label, section: sec.name, box, metrics, pageOverflow: pageMetrics.overflow })
    }

    // full page shot for manual review
    await page.evaluate(() => window.scrollTo(0, 0))
    await page.screenshot({
      path: path.join(OUT, `home-full-${bp.label}.png`),
      fullPage: true,
    })
  }

  // App page quick check
  for (const bp of [breakpoints[0], breakpoints[4], breakpoints[7]]) {
    await page.setViewportSize({ width: bp.w, height: bp.h })
    await page.goto(`${BASE}/app`, { waitUntil: 'networkidle' })
    await page.waitForTimeout(400)
    await page.screenshot({ path: path.join(OUT, `app-${bp.label}.png`), fullPage: true })
    const appMetrics = await page.evaluate(() => ({
      scrollW: document.documentElement.scrollWidth,
      vw: window.innerWidth,
      title: document.title,
      h1: document.querySelector('h1')?.textContent?.trim(),
    }))
    report.push({ page: 'app', bp: bp.label, appMetrics })
  }

  await browser.close()
  await writeFile(path.join(OUT, 'visual-report.json'), JSON.stringify(report, null, 2))
  console.log('Done', report.length, 'entries')
}

main()
