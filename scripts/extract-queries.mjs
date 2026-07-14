import fs from 'fs';

const s = fs.readFileSync('page-bundle.mjs', 'utf8');

// Extract full query functions with where clauses
const queryNames = ['Sa','Ca','wa','Ta','Ea','Da','Oa','ka','Aa','ja','Ma','Na','Pa','La','Fa','Ia','za'];
const queries = {};

for (const name of queryNames) {
  const start = s.indexOf(`${name}=()=>({`);
  if (start === -1) continue;
  let depth = 0, end = start;
  for (let i = start; i < s.length; i++) {
    if (s[i] === '(') depth++;
    if (s[i] === ')') {
      depth--;
      if (depth === 0) { end = i + 1; break; }
    }
  }
  queries[name] = s.slice(start, end + 1);
}

fs.writeFileSync('queries.txt', Object.entries(queries).map(([k,v]) => `=== ${k} ===\n${v}\n`).join('\n'));
console.log('wrote', Object.keys(queries).length, 'queries');

// Find industry filter values in where clauses
for (const [name, q] of Object.entries(queries)) {
  const industryMatch = q.match(/value:`([^`]+)`/g);
  if (industryMatch) console.log(name, industryMatch.join(', '));
}
