const fs = require('fs');
const https = require('https');

const CMS_URL = 'https://framerusercontent.com/cms/8ZCJwP7SzPns2Vksz8BP/bQD6btNnfUi9X4uXSpLQ/eqmxKV824-chunk-default-0.framercms';

// Field mapping from Framer CMS schema
const FIELDS = {
  slug: 'a21S1dHlI', // will detect dynamically
  category: 'kPQHLZGun',
  summary: 'fGu3h5Sjk',
  itchScore: 'yz94alMtN',
  severity: 'xw3OWq62m',
  tam: 'FFirwtqir',
  competition: 'CYuXb1VJn',
  whitespace: 'NSbVUMEKe',
  frequency: 'xI6wUjGnn',
};

function fetch(url) {
  return new Promise((resolve, reject) => {
    https.get(url, { headers: { 'User-Agent': 'Mozilla/5.0' } }, (res) => {
      const chunks = [];
      res.on('data', (c) => chunks.push(c));
      res.on('end', () => resolve(Buffer.concat(chunks)));
    }).on('error', reject);
  });
}

class Reader {
  constructor(buf) {
    this.buf = buf;
    this.off = 0;
    this.view = new DataView(buf.buffer, buf.byteOffset, buf.byteLength);
    this.decoder = new TextDecoder();
  }
  readUint8() { const v = this.view.getUint8(this.off); this.off += 1; return v; }
  readUint16() { const v = this.view.getUint16(this.off); this.off += 2; return v; }
  readUint32() { const v = this.view.getUint32(this.off); this.off += 4; return v; }
  readFloat64() { const v = this.view.getFloat64(this.off); this.off += 8; return v; }
  readInt64() { const v = Number(this.view.getBigInt64(this.off)); this.off += 8; return v; }
  readInt8() { const v = this.view.getInt8(this.off); this.off += 1; return v; }
  readBytes(n) { const s = this.buf.subarray(this.off, this.off + n); this.off += n; return s; }
  readString() { const n = this.readUint32(); return this.decoder.decode(this.readBytes(n)); }
  readJson() { return JSON.parse(this.readString()); }
  readValue() {
    const t = this.readUint8();
    if (t === 0) return null;
    switch (t) {
      case 1: { const n = this.readUint16(); const a = []; for (let i = 0; i < n; i++) a.push(this.readValue()); return a; }
      case 2: return this.readUint8() !== 0;
      case 3: return this.readString();
      case 4: return new Date(this.readInt64()).toISOString();
      case 5: return this.readString();
      case 6: return this.readString();
      case 7: return this.readJson();
      case 8: return this.readFloat64();
      case 9: {
        const n = this.readUint16(); const o = {};
        for (let i = 0; i < n; i++) o[this.readString()] = this.readValue();
        return o;
      }
      case 10: return this.readJson();
      case 11: {
        const k = this.readInt8();
        if (k === 0) return this.readUint32();
        if (k === 1) return this.readString();
        throw new Error('bad rich text');
      }
      case 12: return this.readString();
      case 13: return this.readUint32();
      default: throw new Error('unknown type ' + t);
    }
  }
  readItem() {
    const fc = this.readUint16();
    const fields = {};
    for (let j = 0; j < fc; j++) fields[this.readString()] = this.readValue();
    return fields;
  }
}

function getStr(v) {
  if (v == null) return null;
  if (typeof v === 'string') return v;
  if (typeof v === 'number') return String(v);
  return null;
}

function getNum(v) {
  if (typeof v === 'number') return v;
  if (typeof v === 'string' && !isNaN(parseFloat(v))) return parseFloat(v);
  return null;
}

function normalizeCategory(cat) {
  if (!cat) return 'Other';
  if (cat === 'HealthTech') return 'Healthtech';
  return cat;
}

function normalizeItem(fields) {
  const strings = Object.fromEntries(
    Object.entries(fields).map(([k, v]) => [k, getStr(v)])
  );
  const problem = strings.I35WjSkI0 || Object.values(strings).find(v => v && /^Why /i.test(v)) || strings.fGu3h5Sjk;
  const category = normalizeCategory(strings.kPQHLZGun);
  const score = getNum(fields.yz94alMtN);
  return {
    problem,
    score,
    industry: category,
    category,
    summary: strings.fGu3h5Sjk,
    severity: getNum(fields.xw3OWq62m),
    tam: getNum(fields.FFirwtqir),
    competition: getNum(fields.CYuXb1VJn),
    whitespace: getNum(fields.NSbVUMEKe),
    frequency: getNum(fields.xI6wUjGnn),
    raw: fields,
  };
}

const CATEGORIES = [
  'B2B Services', 'Beauty & Personal Care', 'Consumer Services', 'E-commerce',
  'EdTech', 'FinTech', 'Food & Beverage', 'Home Services', 'Logistics',
  'Payment Issues', 'Real Estate', 'SaaS', 'Transportation', 'Travel',
  'Healthtech', 'Other',
];

const TOP10_MODAL = [
  { problem: "Why is caring for aging parents for sole earners across cities still fragmented & stressful?", overall: 92, category: 'Healthcare' },
  { problem: "Why can't consumers see verified kitchen safety standards on food delivery apps?", overall: 89, category: 'Consumer Services' },
  { problem: "Why do people leaving formal education lack structure, mentorship and clear career guidance?", overall: 88, category: 'Career' },
  { problem: "Why can't renters access verified mold, pests or hazards before signing leases?", overall: 78, category: 'Housing' },
  { problem: "Why do teachers lack real time mental health support at work?", overall: 81, category: 'Healthcare' },
  { problem: "Why can't anxious people find trustworthy non-prescription sleep solutions easily?", overall: 82, category: 'Healthcare' },
  { problem: "Why do STEM students face education loan anxiety from unclear costs in 2026?", overall: 76, category: 'Career' },
  { problem: "Why is distinguishing sprains from fractures impossible without costly hospital visits?", overall: 74, category: 'Healthcare' },
  { problem: "Why can't first time used car buyers verify car histories, conditions and future maintenance costs?", overall: 68, category: 'Automotive' },
  { problem: "Why is connecting specialized hardware to laptops still unreliable and frustrating?", overall: 63, category: 'Hardware' },
];

async function main() {
  const buf = await fetch(CMS_URL);
  const r = new Reader(buf);
  const count = r.readUint32();
  console.error(`Total CMS items: ${count}`);

  const items = [];
  for (let i = 0; i < count; i++) {
    items.push(normalizeItem(r.readItem()));
  }

  const problems = items.filter(i => i.problem && i.score != null);

  const allIndustries = [...new Set(problems.map(p => p.industry))].sort();
  console.error('Industries found:', allIndustries);

  // Group by category
  const byCategory = {};
  for (const cat of CATEGORIES) byCategory[cat] = [];
  for (const p of problems) {
    const cat = p.industry || 'Other';
    if (!byCategory[cat]) byCategory[cat] = [];
    byCategory[cat].push(p);
  }

  // Deduplicate globally by problem text
  const seen = new Set();
  const unique = [];
  for (const p of problems) {
    const key = p.problem.trim().toLowerCase();
    if (!seen.has(key)) { seen.add(key); unique.push(p); }
  }
  unique.sort((a, b) => b.score - a.score);

  const perCategorySummary = CATEGORIES.map(cat => {
    const list = (byCategory[cat] || []).sort((a, b) => b.score - a.score);
    const top = list[0];
    return {
      category: cat,
      count: list.length,
      topScore: top?.score ?? null,
      topProblem: top?.problem ?? null,
    };
  });

  const result = {
    totalUniqueProblems: unique.length,
    totalCmsItems: count,
    perCategorySummary,
    globalTop30: unique.slice(0, 30).map(p => ({ problem: p.problem, score: p.score, industry: p.industry })),
    top10ModalScores: TOP10_MODAL,
    byCategory: Object.fromEntries(
      CATEGORIES.map(cat => [cat, (byCategory[cat] || []).sort((a, b) => b.score - a.score)])
    ),
  };

  const outPath = 'C:/TanmoySaha/Works/Code/FlutterProjects/Splitter/scripts/fix_my_itch_results.json';
  fs.writeFileSync(outPath, JSON.stringify(result, null, 2));
  console.log(JSON.stringify({
    totalUniqueProblems: result.totalUniqueProblems,
    totalCmsItems: result.totalCmsItems,
    perCategorySummary: result.perCategorySummary,
    globalTop30: result.globalTop30,
    top10ModalScores: result.top10ModalScores,
  }, null, 2));
}

main().catch(e => { console.error(e); process.exit(1); });
