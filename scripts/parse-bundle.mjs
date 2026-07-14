import fs from 'fs';

const s = fs.readFileSync('page-bundle.mjs', 'utf8');

// Find query function definitions
const queryFuncs = ['Sa','ja','La','Oa','Pa','Da','Ia','Ea','wa','Ma','Aa','Fa','Ca','Ta','za','ka','Na'];
for (const fn of queryFuncs) {
  const idx = s.indexOf(`function ${fn}(`);
  if (idx === -1) {
    const idx2 = s.indexOf(`${fn}=function`);
    const idx3 = s.indexOf(`${fn}=()=>`);
    console.log(fn, 'not found as function', idx2, idx3);
    if (idx3 > -1) console.log(s.slice(idx3, idx3 + 500));
  } else {
    console.log('\n===', fn, '===');
    console.log(s.slice(idx, idx + 800));
  }
}

// search for industry names
const industries = ['B2B Services','FinTech','Food & Beverage','Healthtech','Payment Issues'];
for (const ind of industries) {
  const i = s.indexOf(ind);
  console.log(ind, i > -1 ? 'found at ' + i : 'not found');
}

// search cms urls
const urls = [...s.matchAll(/https?:\/\/[^"'`\s]+/g)].map(m => m[0]);
const cms = [...new Set(urls)].filter(u => u.includes('cms') || u.includes('collection') || u.includes('framer'));
console.log('\nCMS urls:', cms);
