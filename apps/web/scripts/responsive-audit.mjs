/**
 * Responsive audit script — run while dev server is up at localhost:5173
 * Usage: node scripts/responsive-audit.mjs
 */
import { chromium } from 'playwright'

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
  { path: '/', name: 'Home' },
  { path: '/privacy', name: 'Privacy' },
  { path: '/terms', name: 'Terms' },
  { path: '/refund', name: 'Refund' },
  { path: '/cancellation', name: 'Cancellation' },
  { path: '/contact', name: 'Contact' },
  { path: '/account-deletion', name: 'Account Deletion' },
  { path: '/join/demo-token-abc', name: 'Join Group' },
  { path: '/invite/friend/demo-user-id', name: 'Friend Invite' },
  { path: '/app', name: 'App Login' },
  { path: '/does-not-exist-page', name: '404' },
]

function auditPage() {
  const vw = window.innerWidth
  const vh = window.innerHeight
  const issues = []

  const docW = document.documentElement.scrollWidth
  const bodyW = document.body.scrollWidth
  if (docW > vw + 1 || bodyW > vw + 1) {
    issues.push({
      type: 'horizontal-overflow',
      severity: 'high',
      detail: `doc=${docW} body=${bodyW} vw=${vw}`,
    })
  }

  const offenders = []
  for (const el of document.querySelectorAll('body *')) {
    const style = getComputedStyle(el)
    if (style.display === 'none' || style.visibility === 'hidden' || style.opacity === '0')
      continue
    const rect = el.getBoundingClientRect()
    if (rect.width < 2 || rect.height < 2) continue
    if (rect.right > vw + 1 || rect.left < -1) {
      const tag = el.tagName.toLowerCase()
      const id = el.id ? `#${el.id}` : ''
      const cls =
        el.className && typeof el.className === 'string'
          ? '.' + el.className.trim().split(/\s+/).slice(0, 2).join('.')
          : ''
      offenders.push({
        selector: `${tag}${id}${cls}`,
        right: Math.round(rect.right),
        left: Math.round(rect.left),
        width: Math.round(rect.width),
      })
    }
  }
  if (offenders.length) {
    issues.push({
      type: 'elements-outside-viewport',
      severity: 'high',
      count: offenders.length,
      samples: offenders.slice(0, 10),
    })
  }

  const smallTargets = []
  for (const el of document.querySelectorAll(
    'a, button, input, select, textarea, [role="button"], [tabindex]:not([tabindex="-1"])',
  )) {
    const style = getComputedStyle(el)
    if (style.display === 'none' || style.visibility === 'hidden') continue
    const rect = el.getBoundingClientRect()
    if (rect.width === 0 || rect.height === 0) continue
    if (rect.top > vh || rect.bottom < 0) continue
    if (rect.width < 44 || rect.height < 44) {
      const text = (el.textContent || el.getAttribute('aria-label') || '').trim().slice(0, 50)
      smallTargets.push({ text, w: Math.round(rect.width), h: Math.round(rect.height) })
    }
  }
  if (smallTargets.length) {
    issues.push({
      type: 'small-touch-targets',
      severity: 'medium',
      count: smallTargets.length,
      samples: smallTargets.slice(0, 10),
    })
  }

  const textOverflow = []
  for (const el of document.querySelectorAll('h1,h2,h3,h4,h5,h6,p,span,li,a,button,label,td,th')) {
    const style = getComputedStyle(el)
    if (style.display === 'none' || style.visibility === 'hidden') continue
    const rect = el.getBoundingClientRect()
    if (rect.width === 0 || rect.top > vh || rect.bottom < 0) continue
    if (el.scrollWidth > el.clientWidth + 2 && el.clientWidth > 0) {
      const text = (el.textContent || '').trim().slice(0, 60)
      if (!text) continue
      textOverflow.push({ text, scroll: el.scrollWidth, client: el.clientWidth })
    }
  }
  if (textOverflow.length) {
    issues.push({
      type: 'text-clipped',
      severity: 'medium',
      count: textOverflow.length,
      samples: textOverflow.slice(0, 8),
    })
  }

  return { vw, vh, scrollY: window.scrollY, issues }
}

async function main() {
  const browser = await chromium.launch({ headless: true })
  const context = await browser.newContext()
  const page = await context.newPage()

  const findings = []
  const screenshotDir = new URL('../.responsive-audit-screenshots/', import.meta.url)

  for (const p of pages) {
    await page.goto(`${BASE}${p.path}`, { waitUntil: 'networkidle', timeout: 30000 })
    await page.waitForTimeout(600)
    await page.evaluate(() => {
      localStorage.setItem('splitr_intro_seen', '1')
      document.querySelector('button[aria-label="Close"]')?.click()
    })

    for (const bp of breakpoints) {
      await page.setViewportSize({ width: bp.w, height: bp.h })
      await page.waitForTimeout(350)

      const scrollPoints = await page.evaluate(() => {
        const h = document.documentElement.scrollHeight
        const vh = window.innerHeight
        const pts = [0]
        for (let y = vh * 0.5; y < h; y += vh * 0.7) pts.push(Math.floor(y))
        if (h > vh) pts.push(Math.max(0, h - vh))
        return [...new Set(pts)]
      })

      const bpIssues = []
      for (const y of scrollPoints) {
        await page.evaluate((yy) => window.scrollTo(0, yy), y)
        await page.waitForTimeout(200)
        const audit = await page.evaluate(auditPage)
        if (audit.issues.length) {
          bpIssues.push({ scrollY: y, ...audit })
        }
      }

      if (bpIssues.length) {
        const deduped = dedupeIssues(bpIssues)
        findings.push({
          page: p.name,
          path: p.path,
          breakpoint: bp.label,
          viewport: `${bp.w}x${bp.h}`,
          issueSets: deduped,
        })
      }
    }
  }

  await browser.close()
  console.log(JSON.stringify({ findingsCount: findings.length, findings }, null, 2))
}

function dedupeIssues(sets) {
  const seen = new Set()
  const out = []
  for (const s of sets) {
    for (const iss of s.issues) {
      const key = `${s.scrollY}|${iss.type}|${JSON.stringify(iss.samples || iss.detail || '')}`
      if (seen.has(key)) continue
      seen.add(key)
      out.push({ scrollY: s.scrollY, ...iss })
    }
  }
  return out
}

main().catch((e) => {
  console.error(e)
  process.exit(1)
})
