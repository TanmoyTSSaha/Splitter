import { readFileSync, writeFileSync } from 'node:fs'

const raw = readFileSync('scripts/responsive-audit-results.json', 'utf8').replace(/^\uFEFF/, '')
const data = JSON.parse(raw)

function isFalsePositive(samples) {
  if (!samples?.length) return true
  return samples.every((s) => {
    const sel = (s.selector || '').toLowerCase()
    if (sel.includes('skip-link')) return true
    if (sel.includes('drawer')) return true
    if (s.left < -100) return true
    return false
  })
}

const real = []
for (const f of data.findings) {
  const issueSets = []
  for (const i of f.issueSets) {
    if (i.type === 'elements-outside-viewport' && isFalsePositive(i.samples)) continue
    if (i.type === 'small-touch-targets') {
      const vis = (i.samples || []).filter(
        (s) => !['Close', 'Splitr.'].includes(s.text) && !(s.w >= 44 && s.h < 44),
      )
      if (!vis.length) continue
      issueSets.push({ ...i, samples: vis, count: vis.length })
      continue
    }
    issueSets.push(i)
  }
  if (issueSets.length) real.push({ ...f, issueSets })
}

const byPage = {}
const horiz = []
const clipped = []
for (const f of real) {
  byPage[f.page] = (byPage[f.page] || 0) + 1
  for (const i of f.issueSets) {
    if (i.type === 'horizontal-overflow') horiz.push({ page: f.page, bp: f.breakpoint, detail: i.detail })
    if (i.type === 'text-clipped')
      clipped.push({ page: f.page, bp: f.breakpoint, scrollY: i.scrollY, samples: i.samples })
  }
}

writeFileSync(
  'scripts/responsive-audit-filtered.json',
  JSON.stringify({ realCount: real.length, byPage, horiz, clipped, findings: real }, null, 2),
)
console.log(JSON.stringify({ realCount: real.length, byPage, horizCount: horiz.length, clippedCount: clipped.length }, null, 2))
