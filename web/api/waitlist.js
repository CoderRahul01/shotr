// Vercel serverless function: POST /api/waitlist
// Validates the email and appends it to a Google Sheet through an Apps Script web app.
// Env (Vercel > Project > Settings > Environment Variables):
//   SHEET_WEBHOOK_URL     the Apps Script /exec URL (see docs/google-sheet-waitlist.md)
//   SHEET_WEBHOOK_SECRET  shared secret, must match SECRET in the Apps Script

const EMAIL = /^[^\s@]{1,64}@[^\s@]{1,190}\.[a-z]{2,24}$/i;

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST');
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const body = typeof req.body === 'string' ? safeJson(req.body) : req.body || {};
  const email = String(body.email || '').trim().toLowerCase();
  if (!EMAIL.test(email)) return res.status(400).json({ error: 'Enter a valid email.' });

  const url = process.env.SHEET_WEBHOOK_URL;
  const secret = process.env.SHEET_WEBHOOK_SECRET;
  if (!url || !secret) return res.status(500).json({ error: 'Waitlist is not configured yet.' });

  try {
    const r = await fetch(url, {
      method: 'POST',
      headers: { 'content-type': 'application/json' },
      body: JSON.stringify({
        secret,
        email,
        source: String(body.source || 'landing').slice(0, 40),
        referrer: String(body.referrer || '').slice(0, 200),
        country: String(req.headers['x-vercel-ip-country'] || ''),
        userAgent: String(req.headers['user-agent'] || '').slice(0, 200),
      }),
      redirect: 'follow',
    });
    const out = await r.json().catch(() => ({}));
    if (!r.ok || out.ok !== true) throw new Error(out.error || `sheet ${r.status}`);
    return res.status(200).json({ ok: true, duplicate: out.duplicate === true });
  } catch (e) {
    console.error('waitlist failed', e);
    return res.status(502).json({ error: 'Could not join right now. Try again.' });
  }
}

function safeJson(s) {
  try {
    return JSON.parse(s);
  } catch {
    return {};
  }
}
