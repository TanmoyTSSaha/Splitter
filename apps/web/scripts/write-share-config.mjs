import { mkdir, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const root = path.dirname(fileURLToPath(import.meta.url));
const outDir = path.join(root, '..', 'public', 'share');
const outFile = path.join(outDir, 'config.js');

const supabaseUrl = process.env.VITE_SUPABASE_URL?.trim() ?? '';
const anonKey = process.env.VITE_SUPABASE_ANON_KEY?.trim() ?? '';

const body = `// Generated at build time — do not edit.
window.__SPLITR__ = {
  supabaseUrl: ${JSON.stringify(supabaseUrl)},
  anonKey: ${JSON.stringify(anonKey)},
};
`;

await mkdir(outDir, { recursive: true });
await writeFile(outFile, body, 'utf8');

if (!supabaseUrl || !anonKey) {
  console.warn(
    '[share] VITE_SUPABASE_URL / VITE_SUPABASE_ANON_KEY unset — web reader falls back to app deep link.',
  );
} else {
  console.log('[share] Wrote public/share/config.js for recap web reader.');
}
