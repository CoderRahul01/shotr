// Local dev server: static site + /api/waitlist, no Vercel login needed.
//   SHEET_WEBHOOK_URL=... SHEET_WEBHOOK_SECRET=... node scripts/dev.mjs   (port 3000)
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import { extname, join, normalize } from 'node:path';
import { fileURLToPath } from 'node:url';

import waitlist from '../api/waitlist.js';

const root = fileURLToPath(new URL('..', import.meta.url));
const port = Number(process.env.PORT || 3000);
const types = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.png': 'image/png', '.jpg': 'image/jpeg', '.webp': 'image/webp', '.mp4': 'video/mp4', '.ttf': 'font/ttf', '.json': 'application/json' };

createServer(async (req, res) => {
  const url = new URL(req.url, `http://localhost:${port}`);
  if (url.pathname === '/api/waitlist') {
    let raw = '';
    for await (const c of req) raw += c;
    const shim = {
      setHeader: (k, v) => res.setHeader(k, v),
      status(code) { res.statusCode = code; return this; },
      json(obj) { res.setHeader('content-type', 'application/json'); res.end(JSON.stringify(obj)); return this; },
    };
    return waitlist({ method: req.method, headers: req.headers, body: raw }, shim);
  }
  const path = normalize(url.pathname === '/' ? '/index.html' : url.pathname).replace(/^(\.\.[/\\])+/, '');
  try {
    const data = await readFile(join(root, path));
    res.setHeader('content-type', types[extname(path)] || 'application/octet-stream');
    res.end(data);
  } catch {
    res.statusCode = 404;
    res.end('Not found');
  }
}).listen(port, () => console.log(`shotr web on http://localhost:${port}`));
