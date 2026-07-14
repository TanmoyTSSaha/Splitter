import fs from 'fs';

const html = fs.readFileSync('fix-my-itch.html', 'utf8');
const urls = [...html.matchAll(/https:\/\/framerusercontent\.com\/sites\/6gNMFZ8tUMj34P468SM7Gi\/[^"\s]+\.mjs/g)].map(m => m[0]);
console.log('modules:', [...new Set(urls)].length);
for (const u of [...new Set(urls)]) console.log(u);

// extract problems from HTML text nodes
const problems = [...html.matchAll(/(?:Why|Where|How|What|When)[^<]{20,250}\?/g)].map(m => m[0].replace(/&amp;/g,'&').replace(/&apos;/g,"'"));
const unique = [...new Set(problems)];
console.log('\nproblems in HTML:', unique.length);
unique.forEach(p => console.log(p));
