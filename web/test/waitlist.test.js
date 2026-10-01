import assert from 'node:assert/strict';
import { test } from 'node:test';

import handler from '../api/waitlist.js';

function call(method, body, env = {}) {
  Object.assign(process.env, { SHEET_WEBHOOK_URL: '', SHEET_WEBHOOK_SECRET: '' }, env);
  return new Promise((resolve) => {
    const res = {
      code: 200,
      headers: {},
      setHeader(k, v) { this.headers[k] = v; },
      status(c) { this.code = c; return this; },
      json(j) { resolve({ code: this.code, body: j }); return this; },
    };
    handler({ method, body, headers: {} }, res);
  });
}

test('rejects non-POST', async () => {
  assert.equal((await call('GET')).code, 405);
});

test('rejects bad emails', async () => {
  assert.equal((await call('POST', { email: 'nope' })).code, 400);
});

test('reports missing config', async () => {
  assert.equal((await call('POST', { email: 'a@b.co' })).code, 500);
});

test('forwards to the sheet with the secret', async () => {
  let sent;
  globalThis.fetch = async (url, init) => {
    sent = { url, body: JSON.parse(init.body) };
    return new Response(JSON.stringify({ ok: true }), { status: 200 });
  };
  const r = await call('POST', { email: ' A@B.co ', source: 'landing' }, { SHEET_WEBHOOK_URL: 'https://script.google.com/x/exec', SHEET_WEBHOOK_SECRET: 's3' });
  assert.equal(r.code, 200);
  assert.equal(sent.body.email, 'a@b.co');
  assert.equal(sent.body.secret, 's3');
});

test('sheet failure returns 502', async () => {
  globalThis.fetch = async () => new Response(JSON.stringify({ ok: false, error: 'bad secret' }), { status: 200 });
  const r = await call('POST', { email: 'a@b.co' }, { SHEET_WEBHOOK_URL: 'https://x', SHEET_WEBHOOK_SECRET: 's' });
  assert.equal(r.code, 502);
});
