import { test } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const VALIDATOR = path.join(__dirname, 'validate-env-prod.mjs');
const ENV_EXAMPLE = path.join(__dirname, '..', 'apps', 'mobile', 'env.example.json');

const VALID_FIXTURE = {
  SUPABASE_URL: 'https://abc123xyz.supabase.co',
  SUPABASE_ANON_KEY: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc',
  GOOGLE_WEB_CLIENT_ID: '123456789012-abcdef.apps.googleusercontent.com',
  RAZORPAY_KEY_ID: 'rzp_live_abcdefghijklmnop',
  SENTRY_DSN: 'https://abc123@o123.ingest.sentry.io/456789',
  SENTRY_ENVIRONMENT: 'production',
};

function runValidator(filePath) {
  return spawnSync(process.execPath, [VALIDATOR, filePath], {
    encoding: 'utf8',
  });
}

function writeTempJson(name, data) {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'validate-env-prod-'));
  const filePath = path.join(dir, name);
  fs.writeFileSync(filePath, data);
  return filePath;
}

test('env.example.json fails (placeholder blocklist)', () => {
  const result = runValidator(ENV_EXAMPLE);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /validation failed/);
});

test('synthetic valid fixture passes', () => {
  const filePath = writeTempJson('valid.json', JSON.stringify(VALID_FIXTURE));
  const result = runValidator(filePath);
  assert.equal(result.status, 0);
  assert.match(result.stdout, /env\.prod\.json OK/);
});

test('malformed JSON fails with parse error', () => {
  const filePath = writeTempJson('bad.json', '{ not valid json');
  const result = runValidator(filePath);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /malformed JSON/);
});

test('empty required key fails naming key', () => {
  const fixture = { ...VALID_FIXTURE, SUPABASE_URL: '' };
  const filePath = writeTempJson('empty-url.json', JSON.stringify(fixture));
  const result = runValidator(filePath);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /SUPABASE_URL/);
});

test('invalid GOOGLE_WEB_CLIENT_ID suffix fails', () => {
  const fixture = {
    ...VALID_FIXTURE,
    GOOGLE_WEB_CLIENT_ID: '123456789012-abcdef.googleusercontent.com',
  };
  const filePath = writeTempJson('bad-google.json', JSON.stringify(fixture));
  const result = runValidator(filePath);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /GOOGLE_WEB_CLIENT_ID/);
});

test('invalid RAZORPAY_KEY_ID prefix fails', () => {
  const fixture = { ...VALID_FIXTURE, RAZORPAY_KEY_ID: 'live_rzp_badprefix' };
  const filePath = writeTempJson('bad-razorpay.json', JSON.stringify(fixture));
  const result = runValidator(filePath);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /RAZORPAY_KEY_ID/);
});

test('invalid optional SENTRY_ENVIRONMENT when set fails', () => {
  const fixture = { ...VALID_FIXTURE, SENTRY_ENVIRONMENT: '9bad-start' };
  const filePath = writeTempJson('bad-sentry-env.json', JSON.stringify(fixture));
  const result = runValidator(filePath);
  assert.notEqual(result.status, 0);
  assert.match(result.stderr, /SENTRY_ENVIRONMENT/);
});
