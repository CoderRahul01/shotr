"""Builds brag.html: a 1920x1080 composition. Every animation is scrubbed by frames.mjs
(currentTime = t - scene start), so each frame is a pure function of time."""
import re, os, json
HERE = os.path.dirname(os.path.abspath(__file__))
CAN = os.path.join(HERE, "..", "canvas", "project")
ACC = "#e4f222"

def board(name, holes):
    src = open(os.path.join(CAN, name)).read()
    css = "\n".join(re.findall(r"<style>(.*?)</style>", src, re.S))
    body = re.search(r"</helmet>(.*?)</x-dc>", src, re.S).group(1)
    body = body.replace("{{accent}}", ACC)
    for k, v in holes.items():
        body = body.replace("{{" + k + "}}", str(v))
    return css, body

css_all = []
def phone(name, holes, scale=1.0, extra=""):
    css, body = board(name, holes)
    css_all.append(css)
    w, h = round(390 * scale), round(844 * scale)
    return (f'<div class="phone" style="width:{w + 24}px;height:{h + 24}px;{extra}">'
            f'<div style="width:{w}px;height:{h}px;border-radius:40px;overflow:hidden;position:relative">'
            f'<div style="width:390px;height:844px;transform:scale({scale});transform-origin:top left">{body}</div></div></div>')

share = phone("ShareSheet.dc.html", {}, 1.08)
home = phone("Home.dc.html", {"n": 12}, 1.08)
result = phone("Result.dc.html", {}, 1.08)

T = 21.0
def thumbs():
    kinds = ["post", "job", "article", "chart", "thread", "ui"]
    out = ""
    for i in range(24):
        k = kinds[(i * 7) % 6]
        col, row = i % 8, i // 8
        out += (f'<div class="g" style="left:{120 + col * 214}px;top:{150 + row * 270}px;animation-delay:{0.04 * i:.2f}s">'
                f'<div class="th">{"".join(lines(k))}</div></div>')
    return out
def lines(k):
    if k == "chart":
        return ['<div class="l2" style="width:40%"></div><div style="flex:1;display:flex;align-items:flex-end;gap:6px">'
                + "".join(f'<div style="flex:1;height:{p}%;background:#383b3f;border-radius:3px 3px 0 0"></div>' for p in (40, 70, 55, 90, 75)) + '</div>']
    ws = {"post": (45, 92, 80, 86), "job": (60, 85, 70, 50), "article": (75, 50, 95, 88), "thread": (85, 90, 60, 80), "ui": (100, 100, 60, 40)}[k]
    return [f'<div class="l{1 if j < 2 else 2}" style="width:{w}%"></div>' for j, w in enumerate(ws)] + ['<div style="flex:1;background:#23252a;border-radius:6px;margin-top:6px"></div>']

def corners(c=ACC, s=28, o=-10, w=3):
    return "".join(f'<span style="position:absolute;width:{s}px;height:{s}px;{p};border:0 solid {c};{b}"></span>'
                   for p, b in ((f"top:{o}px;left:{o}px", f"border-top-width:{w}px;border-left-width:{w}px"),
                                (f"top:{o}px;right:{o}px", f"border-top-width:{w}px;border-right-width:{w}px"),
                                (f"bottom:{o}px;left:{o}px", f"border-bottom-width:{w}px;border-left-width:{w}px"),
                                (f"bottom:{o}px;right:{o}px", f"border-bottom-width:{w}px;border-right-width:{w}px")))

def logo(px):
    b = round(px * 1.1); c = round(b * 0.32)
    return (f'<div style="display:flex;align-items:center;gap:{round(px * .55)}px"><div style="position:relative;width:{b}px;height:{b}px">'
            f'{corners(ACC, c, 0, max(2, round(px / 14)))}<span style="position:absolute;left:50%;top:50%;width:{round(px / 5)}px;height:{round(px / 5)}px;transform:translate(-50%,-50%);border-radius:50%;background:{ACC}"></span></div>'
            f'<span style="font-size:{px}px;font-weight:600;letter-spacing:-0.02em">shotr</span></div>')

outs = [("Startup playbook", "X/LinkedIn post", "A 3-person team didn't launch to everyone. They picked their first 100 users by hand."),
        ("Hiring post", "Cold email", "Hi [Name], saw you're hiring a founding engineer. Open to a 15-minute call?"),
        ("Product idea", "Build note", "Try: a share sheet that closes in under a second. Test with 5 users Friday."),
        ("Learning", "Takeaways", "1. Hooks beat headlines. 2. One idea per post. 3. End with a real question.")]
cards = "".join(
    f'<div class="oc" style="animation-delay:{0.5 + i * 0.45:.2f}s"><div class="mono"><span style="color:#8a8f98">{a}</span>  →  <span style="color:#fff">{b}</span></div>'
    f'<p>{c}</p><span class="badge">AI draft · your voice</span></div>' for i, (a, b, c) in enumerate(outs))

SCENES = [(0, 3.0), (3.0, 6.0), (6.0, 10.0), (10.0, 14.0), (14.0, 18.0), (18.0, 21.0)]

html = f"""<!doctype html><html><head><meta charset="utf-8"><link rel="stylesheet" href="local.css">
<style>
{''.join(css_all)}
html,body{{margin:0;background:#08090a;overflow:hidden}}
#v{{position:relative;width:1920px;height:1080px;background:#08090a;color:#fff;font-family:Inter,system-ui,sans-serif;overflow:hidden;font-feature-settings:"cv01","ss03";-webkit-font-smoothing:antialiased}}
.sc{{position:absolute;inset:0}}
.mono{{font-family:"Geist Mono",monospace;font-size:18px;letter-spacing:.06em;text-transform:uppercase;color:#8a8f98}}
.big{{font-size:96px;font-weight:600;letter-spacing:-0.045em;line-height:1}}
.cap{{font-size:64px;font-weight:600;letter-spacing:-0.035em;line-height:1.05}}
.phone{{border-radius:52px;background:#0f1011;box-shadow:inset 0 0 0 1px #2a2c31,0 60px 120px rgba(0,0,0,.6);padding:12px;box-sizing:border-box;position:absolute}}
.g{{position:absolute;width:180px;height:240px;animation:drop .5s cubic-bezier(.2,.8,.2,1) both}}
.th{{width:100%;height:100%;background:#161718;border-radius:10px;padding:16px;box-sizing:border-box;display:flex;flex-direction:column;gap:9px}}
.l1{{height:8px;border-radius:4px;background:#383b3f}}.l2{{height:8px;border-radius:4px;background:#23252a}}
@keyframes drop{{from{{opacity:0;transform:translateY(-60px) rotate(-4deg)}}to{{opacity:1;transform:none}}}}
@keyframes inout{{0%{{opacity:0}}100%{{opacity:1}}}}
@keyframes up{{from{{opacity:0;transform:translateY(30px)}}to{{opacity:1;transform:none}}}}
.up{{animation:up .7s cubic-bezier(.2,.8,.2,1) both}}
.oc{{background:#0f1011;border-radius:18px;box-shadow:inset 0 0 0 1px #23252a,inset 0 1px 0 rgba(255,255,255,.04);padding:32px;display:flex;flex-direction:column;gap:18px;animation:up .6s cubic-bezier(.2,.8,.2,1) both}}
.oc p{{margin:0;font-size:28px;line-height:1.4;letter-spacing:-0.01em}}
.badge{{align-self:flex-start;height:28px;padding:0 10px;border-radius:6px;background:rgba(255,255,255,.06);font-family:"Geist Mono",monospace;font-size:14px;letter-spacing:.04em;text-transform:uppercase;color:#d0d6e0;display:inline-flex;align-items:center}}
</style></head><body><div id="v">

<!-- 1 HOOK -->
<div class="sc" data-start="0" id="s1">
  {thumbs()}
  <div id="dim" style="position:absolute;inset:0;background:#08090a"></div>
  <div class="up" style="position:absolute;left:0;right:0;top:440px;text-align:center;animation-delay:1.1s"><div class="big">Screenshots you'll never open.</div></div>
</div>

<!-- 2 REVEAL -->
<div class="sc" data-start="3" id="s2" style="display:flex;align-items:center;justify-content:center">
  <div id="shut" style="width:200px;height:200px;border-radius:50%;border:4px solid #fff;display:flex;align-items:center;justify-content:center;box-sizing:border-box">
    <div id="disc" style="width:172px;height:172px;border-radius:50%;background:{ACC};color:#08090a;font-size:34px;font-weight:600;display:flex;align-items:center;justify-content:center">Make</div></div>
  <div id="flash" style="position:absolute;inset:0;background:#fff"></div>
  <div id="rev" style="position:absolute;left:0;right:0;top:330px;display:flex;flex-direction:column;align-items:center;gap:56px">
    {logo(56)}
    <div class="big" style="font-size:120px;text-align:center">Take screenshot.<br>Make a shot.</div>
  </div>
</div>

<!-- 3 SHARE -->
<div class="sc" data-start="6" id="s3">
  <div id="p1" style="position:absolute;left:220px;top:60px">{share.replace('class="phone"', 'class="phone" style="position:relative"', 1) if False else share}</div>
  <div class="up" style="position:absolute;left:900px;top:380px;animation-delay:.5s">
    <div class="mono" style="margin-bottom:28px">01 · Share</div>
    <div class="cap">Share it from any app.<br><span style="color:#8a8f98">Sorted on your phone.</span></div>
  </div>
  <div id="tap1" style="position:absolute;width:64px;height:64px;border-radius:50%;background:rgba(255,255,255,.35);left:487px;top:893px"></div>
</div>

<!-- 4 MAKE -->
<div class="sc" data-start="10" id="s4">
  <div id="p2" style="position:absolute;left:220px;top:60px">{home}</div>
  <div id="p3" style="position:absolute;left:220px;top:60px">{result}</div>
  <div id="tap2" style="position:absolute;width:64px;height:64px;border-radius:50%;background:rgba(255,255,255,.35);left:547px;top:430px"></div>
  <div class="up" style="position:absolute;left:900px;top:380px;animation-delay:.5s">
    <div class="mono" style="margin-bottom:28px">02 · Make</div>
    <div class="cap">One tap.<br><span style="color:#8a8f98">A draft in your voice.</span></div>
  </div>
</div>

<!-- 5 OUTPUTS -->
<div class="sc" data-start="14" id="s5">
  <div class="up" style="position:absolute;left:160px;top:110px"><div class="mono" style="margin-bottom:24px">03 · Every screenshot has a job</div><div class="cap">Posts. Cold emails. Build notes. Takeaways.</div></div>
  <div style="position:absolute;left:160px;right:160px;top:400px;display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:28px">{cards}</div>
</div>

<!-- 6 OUTRO -->
<div class="sc" data-start="18" id="s6" style="display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center">
  <div class="up">{logo(48)}</div>
  <div class="up" style="position:relative;margin-top:56px;padding:36px 56px;animation-delay:.15s">{corners(ACC, 40, 0, 4)}<div class="big" style="font-size:112px">Take screenshot.<br>Make a shot.</div></div>
  <div class="up mono" style="margin-top:48px;font-size:22px;animation-delay:.35s">Free to start · Pro $19/month</div>
  <div class="up" style="margin-top:36px;height:72px;padding:0 36px;border-radius:16px;background:{ACC};color:#08090a;font-size:26px;font-weight:600;display:flex;align-items:center;animation-delay:.5s">Join the waitlist</div>
</div>

</div>
<script>
// scene-level choreography as a pure function of time
const S = {json.dumps([list(s) for s in SCENES])};
const ease = (x) => 1 - Math.pow(1 - Math.min(1, Math.max(0, x)), 3);
const lerp = (a, b, x) => a + (b - a) * x;
window.renderAt = (t) => {{
  // scene windows: dip through background between scenes
  document.querySelectorAll('#v > .sc').forEach((el, i) => {{
    const [a, b] = S[i];
    const fi = i === 0 ? ease((t - a) / 0.25) : ease((t - a) / 0.35);
    const fo = i === S.length - 1 ? 1 : 1 - ease((t - (b - 0.3)) / 0.3);
    const v = (t < a || t > b) ? 0 : Math.min(fi, fo);
    el.style.opacity = v; el.style.visibility = v > 0 ? 'visible' : 'hidden';
    // local clock for all CSS animations inside the scene
    for (const an of el.getAnimations({{ subtree: true }})) {{ an.pause(); an.currentTime = Math.max(0, (t - a)) * 1000; }}
  }});
  // 1: dim the pile under the line
  document.getElementById('dim').style.opacity = 0.82 * ease((t - 1.0) / 0.5);
  // 2: shutter in, press, flash, reveal
  const sh = document.getElementById('shut'), disc = document.getElementById('disc');
  const si = ease((t - 3.0) / 0.4), press = t > 4.0 && t < 4.15 ? 0.86 : 1;
  sh.style.transform = `scale(${{lerp(0.6, 1, si)}})`; disc.style.transform = `scale(${{press}})`;
  sh.style.opacity = t < 4.2 ? si : 0;
  const fl = document.getElementById('flash');
  fl.style.opacity = t < 4.1 ? 0 : 0.95 * (1 - ease((t - 4.1) / 0.45));
  const rv = document.getElementById('rev'); const r = ease((t - 4.25) / 0.5);
  rv.style.opacity = r; rv.style.transform = `translateY(${{lerp(24, 0, r)}}px)`;
  // 3: phone in, tap on Save
  const p1 = document.getElementById('p1'); const pi = ease((t - 6.0) / 0.6);
  p1.style.transform = `translateY(${{lerp(80, 0, pi)}}px)`;
  const tap1 = document.getElementById('tap1'); const k1 = (t - 8.6) / 0.35;
  tap1.style.opacity = k1 > 0 && k1 < 1 ? 1 - k1 : 0; tap1.style.transform = `scale(${{lerp(0.6, 1.5, Math.min(1, Math.max(0, k1)))}})`;
  // 4: home, tap shutter, swap to result
  const p2 = document.getElementById('p2'), p3 = document.getElementById('p3');
  const sw = ease((t - 11.6) / 0.45);
  p2.style.opacity = 1 - sw; p3.style.opacity = sw;
  p2.style.transform = `scale(${{lerp(1, 0.97, sw)}})`; p3.style.transform = `translateY(${{lerp(30, 0, sw)}}px)`;
  const tap2 = document.getElementById('tap2'); const k2 = (t - 11.2) / 0.35;
  tap2.style.opacity = k2 > 0 && k2 < 1 ? 1 - k2 : 0; tap2.style.transform = `scale(${{lerp(0.6, 1.5, Math.min(1, Math.max(0, k2)))}})`;
  // result draft paragraphs: re-clock relative to the swap
  for (const an of p3.getAnimations({{ subtree: true }})) {{ an.pause(); an.currentTime = Math.max(0, t - 11.7) * 1000; }}
}};
</script></body></html>"""
open(os.path.join(HERE, "brag.html"), "w").write(html)
print("ok", len(html))
