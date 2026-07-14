import fs from 'fs';

const s = fs.readFileSync('page-bundle.mjs', 'utf8');

// extract wr collection definition
const wrIdx = s.indexOf('wr={');
if (wrIdx > -1) {
  // find matching brace end - take chunk
  console.log('wr at', wrIdx);
  console.log(s.slice(wrIdx, wrIdx + 3000));
}

// extract all query functions with where clauses
const matches = [...s.matchAll(/([A-Za-z]{2})=\(\)=>\(\{from:\{alias:`vk_xuQdtM`[\s\S]{0,1200}?\}\)/g)];
console.log('\nquery count', matches.length);
for (const m of matches.slice(0, 20)) {
  console.log('\n---', m[1], '---');
  console.log(m[0].slice(0, 600));
}
