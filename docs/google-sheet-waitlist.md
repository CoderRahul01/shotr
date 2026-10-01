# Waitlist -> Google Sheet

The landing page posts to `/api/waitlist` (Vercel function), which appends a row to a Google Sheet
through a small Apps Script. Free, no service account, and you can watch signups live.

## 1. Create the sheet

1. New Google Sheet, name it **shotr waitlist**.
2. Row 1 headers: `timestamp | email | source | referrer | country | user_agent`

## 2. Add the Apps Script

**Extensions > Apps Script**, replace the code with this, and set your own `SECRET`:

```js
const SECRET = 'CHANGE_ME_TO_A_LONG_RANDOM_STRING';

function doPost(e) {
  const out = (o) => ContentService.createTextOutput(JSON.stringify(o)).setMimeType(ContentService.MimeType.JSON);
  let data;
  try { data = JSON.parse(e.postData.contents); } catch (err) { return out({ ok: false, error: 'bad json' }); }
  if (data.secret !== SECRET) return out({ ok: false, error: 'bad secret' });

  const email = String(data.email || '').trim().toLowerCase();
  if (!/^[^\s@]+@[^\s@]+\.[a-z]{2,}$/i.test(email)) return out({ ok: false, error: 'bad email' });

  const lock = LockService.getScriptLock();
  lock.waitLock(10000);
  try {
    const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheets()[0];
    const last = sheet.getLastRow();
    const existing = last > 1 ? sheet.getRange(2, 2, last - 1, 1).getValues().flat() : [];
    if (existing.includes(email)) return out({ ok: true, duplicate: true });
    sheet.appendRow([new Date(), email, data.source || '', data.referrer || '', data.country || '', data.userAgent || '']);
    return out({ ok: true });
  } finally {
    lock.releaseLock();
  }
}
```

## 3. Deploy it

1. **Deploy > New deployment > Web app**
2. Execute as: **Me**. Who has access: **Anyone**.
3. Copy the **Web app URL** (ends in `/exec`).

## 4. Connect Vercel

In Vercel > Project > Settings > Environment Variables (Production and Preview):

| Name | Value |
|---|---|
| `SHEET_WEBHOOK_URL` | the `/exec` URL |
| `SHEET_WEBHOOK_SECRET` | the same `SECRET` as in the script |

Redeploy. Submit your own email on the live site and check the sheet.

Count of test users: the sheet's row count minus 1, or add `=COUNTA(B2:B)` in any cell.
