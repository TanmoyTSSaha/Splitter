#!/usr/bin/env node
/**
 * Production env validator for apps/mobile/env.prod.json (AUTH-01).
 * Node built-ins only — zero npm deps.
 */
import fs from 'node:fs';

const path = process.argv[2] ?? 'apps/mobile/env.prod.json';

const REQUIRED_KEYS = [
  'SUPABASE_URL',
  'SUPABASE_ANON_KEY',
  'GOOGLE_WEB_CLIENT_ID',
  'RAZORPAY_KEY_ID',
  'SENTRY_DSN',
];

const BLOCKLIST = ['your-project', 'your-anon-key', 'YOUR_WEB_CLIENT_ID'];

const OPTIONAL_KEYS = [
  'GEMINI_API_KEY',
  'SENTRY_ENVIRONMENT',
  'SUPABASE_PASSWORD',
  'SUPABASE_DB_URL',
];

const errors = [];

function reject(key, msg) {
  errors.push(`${key}: ${msg}`);
}

function isNonEmptyString(value) {
  return typeof value === 'string' && value.length > 0;
}

let raw;
try {
  raw = fs.readFileSync(path, 'utf8');
} catch (err) {
  console.error(`env.prod.json validation failed: cannot read ${path}: ${err.message}`);
  process.exit(1);
}

let env;
try {
  env = JSON.parse(raw);
} catch (err) {
  console.error(`env.prod.json validation failed: malformed JSON in ${path}: ${err.message}`);
  process.exit(1);
}

if (typeof env !== 'object' || env === null || Array.isArray(env)) {
  console.error(`env.prod.json validation failed: root must be a JSON object in ${path}`);
  process.exit(1);
}

function checkBlocklist(key, value) {
  for (const fragment of BLOCKLIST) {
    if (value.includes(fragment)) {
      reject(key, `contains placeholder fragment "${fragment}"`);
      return;
    }
  }
}

function validateRequired(key) {
  const value = env[key];
  if (!isNonEmptyString(value)) {
    reject(key, 'required key is missing or empty');
    return;
  }
  checkBlocklist(key, value);

  switch (key) {
    case 'SUPABASE_URL':
      if (!/^https:\/\/[a-z0-9-]+\.supabase\.co$/.test(value)) {
        reject(key, 'must match https://<project-ref>.supabase.co');
      }
      break;
    case 'SUPABASE_ANON_KEY':
      if (value.length < 20) {
        reject(key, 'must be at least 20 characters');
      }
      break;
    case 'GOOGLE_WEB_CLIENT_ID':
      if (!value.endsWith('.apps.googleusercontent.com')) {
        reject(key, 'must end with .apps.googleusercontent.com');
      }
      break;
    case 'RAZORPAY_KEY_ID':
      if (!value.startsWith('rzp_')) {
        reject(key, 'must start with rzp_');
      }
      break;
    case 'SENTRY_DSN':
      if (
        !value.startsWith('https://') ||
        !value.includes('@') ||
        !value.includes('sentry.io')
      ) {
        reject(key, 'must be a valid Sentry DSN (https://...@...sentry.io/...)');
      }
      break;
    default:
      break;
  }
}

function validateOptional(key) {
  const value = env[key];
  if (!isNonEmptyString(value)) {
    return;
  }

  switch (key) {
    case 'GEMINI_API_KEY':
      if (value.length < 10) {
        reject(key, 'must be at least 10 characters when set');
      }
      break;
    case 'SENTRY_ENVIRONMENT':
      if (!/^[a-zA-Z][a-zA-Z0-9_-]{0,31}$/.test(value)) {
        reject(key, 'must match ^[a-zA-Z][a-zA-Z0-9_-]{0,31}$ when set');
      }
      break;
    case 'SUPABASE_PASSWORD':
      if (value.length < 8) {
        reject(key, 'must be at least 8 characters when set');
      }
      break;
    case 'SUPABASE_DB_URL':
      if (!/^postgres(ql)?:\/\//.test(value)) {
        reject(key, 'must be a postgres connection string when set');
      }
      break;
    default:
      break;
  }
}

for (const key of REQUIRED_KEYS) {
  validateRequired(key);
}

for (const key of OPTIONAL_KEYS) {
  validateOptional(key);
}

if (errors.length) {
  console.error('env.prod.json validation failed:');
  for (const err of errors) {
    console.error(`  - ${err}`);
  }
  process.exit(1);
}

console.log('env.prod.json OK');
