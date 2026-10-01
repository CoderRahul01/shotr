// shotr landing motion. Every effect respects prefers-reduced-motion and degrades to a static,
// complete layout. No libraries.
(() => {
  const reduce = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const $ = (s, r = document) => r.querySelector(s);
  const $$ = (s, r = document) => Array.from(r.querySelectorAll(s));
  const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
  const ease = (t) => 1 - Math.pow(1 - Math.min(1, Math.max(0, t)), 3);
  const lerp = (a, b, t) => a + (b - a) * t;

  // ---------- nav border on scroll ----------
  const nav = $('.nav');
  const onScrollNav = () => nav && nav.classList.toggle('scrolled', window.scrollY > 8);
  window.addEventListener('scroll', onScrollNav, { passive: true });
  onScrollNav();

  // ---------- headline: viewfinder locks onto "Make a shot." ----------
  const lock = $('.lock');
  if (lock) setTimeout(() => lock.classList.remove('unlocked'), reduce ? 0 : 900);

  // ---------- cursor viewfinder in the hero ----------
  const hero = $('.hero');
  const cvf = $('.cursor-vf');
  if (hero && cvf && !reduce && window.matchMedia('(hover: hover)').matches) {
    let tx = 0, ty = 0, x = 0, y = 0, raf = 0;
    const loop = () => {
      x = lerp(x, tx, 0.18); y = lerp(y, ty, 0.18);
      cvf.style.transform = `translate(${x - 32}px, ${y - 32}px)`;
      raf = Math.abs(x - tx) + Math.abs(y - ty) > 0.3 ? requestAnimationFrame(loop) : 0;
    };
    hero.addEventListener('pointermove', (e) => {
      const r = hero.getBoundingClientRect();
      tx = e.clientX - r.left; ty = e.clientY - r.top;
      if (!raf) raf = requestAnimationFrame(loop);
    });
  }

  // ---------- reveal on scroll ----------
  const io = new IntersectionObserver((entries) => {
    for (const e of entries) if (e.isIntersecting) { e.target.classList.add('in'); io.unobserve(e.target); }
  }, { rootMargin: '0px 0px -10% 0px' });
  $$('.reveal').forEach((el) => (reduce ? el.classList.add('in') : io.observe(el)));

  // ---------- HUD timecode ----------
  const tc = $('#timecode');
  if (tc && !reduce) {
    const t0 = performance.now();
    const tick = () => {
      const s = (performance.now() - t0) / 1000;
      const f = Math.floor((s % 1) * 30);
      const pad = (n) => String(n).padStart(2, '0');
      tc.textContent = `00:${pad(Math.floor(s / 60) % 60)}:${pad(Math.floor(s) % 60)}:${pad(f)}`;
      requestAnimationFrame(tick);
    };
    requestAnimationFrame(tick);
  }

  // ---------- live product demo in the phone ----------
  const demo = $('#demo');
  if (demo) {
    const L = (n) => $(`[data-layer="${n}"]`, demo);
    const show = (n) => $$('.layer', demo).forEach((l) => l.classList.toggle('on', l.dataset.layer === n));
    const tapAt = (el) => {
      const tap = $('.tap', demo), sr = $('.screen', demo).getBoundingClientRect(), r = el.getBoundingClientRect();
      tap.style.left = `${r.left - sr.left + r.width / 2}px`;
      tap.style.top = `${r.top - sr.top + r.height / 2}px`;
      tap.classList.remove('go'); void tap.offsetWidth; tap.classList.add('go');
    };
    const words = $$('.post .w', demo);
    const sheet = $('.sheet', demo), chip = $('#det-chip', demo), save = $('#save-btn', demo);
    const count = $('#count', demo), shutter = $('.shutter', demo), draft = $('#draft', demo), toast = $('.toast', demo);
    const flash = $('.screen-flash', demo), scan = $('.scan', demo);
    const DRAFT = "Subject: Founding engineer role\n\nHi [Name],\nSaw you're hiring a founding engineer. I've shipped two dev tools from zero, solo.\n\nOpen to a 15-minute call this week?";

    const finalState = () => {
      show('result');
      draft.textContent = DRAFT;
      toast.classList.add('up');
    };

    const reset = () => {
      words.forEach((w) => w.classList.remove('hit'));
      sheet.classList.remove('up'); toast.classList.remove('up');
      chip.textContent = 'Reading…'; save.textContent = 'Save';
      count.textContent = '12'; draft.textContent = '';
      scan.classList.remove('run');
    };

    const run = async () => {
      let visible = true;
      new IntersectionObserver(([e]) => { visible = e.isIntersecting; }).observe(demo);
      for (;;) {
        while (!visible || document.hidden) await sleep(400);
        reset(); show('source');
        await sleep(700);
        flash.classList.remove('go'); void flash.offsetWidth; flash.classList.add('go');       // screenshot
        await sleep(700);
        sheet.classList.add('up');                                                              // share -> sheet
        await sleep(450);
        scan.classList.add('run');                                                              // read on device
        for (const w of words) { w.classList.add('hit'); await sleep(55); }
        await sleep(250);
        chip.textContent = 'Hiring post'; chip.classList.remove('pop'); void chip.offsetWidth; chip.classList.add('pop');
        await sleep(1100);
        tapAt(save); save.textContent = 'Saved';                                                // save
        await sleep(650);
        sheet.classList.remove('up');
        await sleep(350);
        show('home');                                                                           // home
        await sleep(500);
        count.textContent = '13';
        await sleep(1100);
        tapAt(shutter); shutter.classList.add('press');                                         // make
        await sleep(160); shutter.classList.remove('press');
        await sleep(300);
        show('result');                                                                         // draft types out
        for (let i = 0; i <= DRAFT.length; i++) {
          draft.textContent = DRAFT.slice(0, i);
          await sleep(DRAFT[i - 1] === '\n' ? 140 : 16);
        }
        await sleep(500);
        toast.classList.add('up');                                                              // shared, made
        await sleep(2600);
      }
    };
    reduce ? finalState() : run();
  }

  // ---------- video controls ----------
  const vid = $('#film');
  if (vid) {
    const play = $('#film-play'), sound = $('#film-sound');
    const sync = () => {
      play.textContent = vid.paused ? 'Play' : 'Pause';
      play.setAttribute('aria-label', vid.paused ? 'Play video' : 'Pause video');
      sound.textContent = vid.muted ? 'Sound on' : 'Sound off';
      sound.setAttribute('aria-pressed', String(!vid.muted));
    };
    if (reduce) { vid.removeAttribute('autoplay'); vid.pause(); }
    else new IntersectionObserver(([e]) => { if (e.isIntersecting) vid.play().catch(sync); else vid.pause(); }, { threshold: 0.35 }).observe(vid);
    play.addEventListener('click', () => (vid.paused ? vid.play().catch(sync) : vid.pause()));
    sound.addEventListener('click', () => { vid.muted = !vid.muted; if (!vid.muted) vid.play().catch(sync); sync(); });
    vid.addEventListener('play', sync); vid.addEventListener('pause', sync);
    sync();
  }

  // ---------- scroll-driven sort: a messy gallery becomes four sorted stacks ----------
  const sort = $('.sort');
  if (sort) {
    const field = $('.sort-field', sort);
    const cats = [['Hiring post', 3], ['Playbook', 4], ['AI update', 3], ['Learning', 2]];
    const shots = [];
    const rand = (i) => { const x = Math.sin(i * 999.13) * 10000; return x - Math.floor(x); };
    cats.forEach(([label, n], ci) => {
      for (let j = 0; j < n; j++) {
        const el = document.createElement('div');
        el.className = 'shot';
        el.setAttribute('aria-hidden', 'true');
        const k = shots.length;
        el.innerHTML = `<div class="l" style="width:${50 + rand(k) * 40}%"></div><div class="l2" style="width:${70 + rand(k + 7) * 25}%"></div><div class="l2" style="width:${55 + rand(k + 3) * 35}%"></div><div class="l2" style="width:${40 + rand(k + 5) * 40}%"></div><div class="k">${label}</div>`;
        field.appendChild(el);
        shots.push({ el, ci, j, r: rand(k), r2: rand(k + 11), r3: rand(k + 23) });
      }
    });
    const labels = $$('.col-label', sort), counts = $$('.col-label .n', sort), bar = $('.sort-progress b', sort);

    const layout = () => {
      const W = field.clientWidth, H = field.clientHeight;
      const sw = shots[0].el.offsetWidth, sh = shots[0].el.offsetHeight;
      const colW = W / 4;
      labels.forEach((l, i) => { l.style.left = `${i * colW + 6}px`; l.style.width = `${colW - 12}px`; });
      const rect = sort.getBoundingClientRect();
      const total = sort.offsetHeight - window.innerHeight;
      const p = reduce ? 1 : Math.min(1, Math.max(0, -rect.top / Math.max(1, total)));
      bar.style.width = `${p * 100}%`;
      shots.forEach((s, i) => {
        const t = ease((p - 0.08 - i * 0.025) / 0.55);
        const N = shots.length, slot = (i * 5) % N; // spread the pile across the full width
        const x0 = ((slot + 0.5) / N) * (W - sw) + (s.r - 0.5) * 40, y0 = 48 + s.r2 * Math.max(0, H - sh - 48), rot0 = (s.r3 - 0.5) * 34;
        const x1 = s.ci * colW + (colW - sw) / 2, y1 = 56 + s.j * Math.min(28, sh * 0.22), rot1 = (s.j - 1) * 1.5;
        s.el.style.transform = `translate(${lerp(x0, x1, t)}px, ${lerp(y0, y1, t)}px) rotate(${lerp(rot0, rot1, t)}deg)`;
        s.el.style.zIndex = String(10 + s.j);
        s.el.style.setProperty('--k', t > 0.9 ? '1' : '0');
      });
      counts.forEach((c, ci) => {
        const inCol = shots.filter((s) => s.ci === ci && ease((p - 0.08 - shots.indexOf(s) * 0.025) / 0.55) > 0.95).length;
        c.textContent = String(inCol);
      });
      labels.forEach((l) => (l.style.opacity = String(Math.min(1, p * 4))));
    };
    let ticking = false;
    const onScroll = () => { if (!ticking) { ticking = true; requestAnimationFrame(() => { layout(); ticking = false; }); } };
    window.addEventListener('scroll', onScroll, { passive: true });
    window.addEventListener('resize', onScroll);
    layout();
  }

  // ---------- one screenshot, four outcomes (tabs that type) ----------
  const out = $('#outcomes');
  if (out) {
    const tabs = $$('.tab', out), text = $('.out-text', out), src = $('#out-src', out);
    const data = tabs.map((t) => ({ src: t.dataset.src, text: t.dataset.text }));
    let idx = 0, timer = 0, typing = 0, visible = false;
    const select = async (i, user) => {
      idx = i;
      tabs.forEach((t, k) => {
        t.setAttribute('aria-selected', String(k === i));
        t.tabIndex = k === i ? 0 : -1;
        const b = $('.bar', t); b.style.transition = 'none'; b.style.width = '0';
        if (k === i && !reduce && !user) requestAnimationFrame(() => { b.style.transition = 'width 5.2s linear'; b.style.width = '100%'; });
      });
      src.textContent = data[i].src;
      const my = ++typing;
      if (reduce) { text.textContent = data[i].text; return; }
      text.textContent = '';
      for (let c = 0; c <= data[i].text.length; c++) {
        if (my !== typing) return;
        text.textContent = data[i].text.slice(0, c);
        await sleep(14);
      }
    };
    const cycle = () => { clearTimeout(timer); if (!reduce && visible) timer = setTimeout(() => { select((idx + 1) % tabs.length); cycle(); }, 5600); };
    tabs.forEach((t, i) => {
      t.addEventListener('click', () => { select(i, true); clearTimeout(timer); });
      t.addEventListener('keydown', (e) => {
        if (e.key !== 'ArrowRight' && e.key !== 'ArrowLeft') return;
        const n = (i + (e.key === 'ArrowRight' ? 1 : tabs.length - 1)) % tabs.length;
        tabs[n].focus(); select(n, true); clearTimeout(timer);
      });
    });
    new IntersectionObserver(([e]) => {
      const was = visible; visible = e.isIntersecting;
      if (visible && !was) { select(idx); cycle(); } else if (!visible) clearTimeout(timer);
    }, { threshold: 0.4 }).observe(out);
    select(0, true);
  }

  // ---------- "sorted" step: rows reorder ----------
  const list = $('.viz-sort ul');
  if (list && !reduce) {
    setInterval(() => { const first = list.firstElementChild; list.appendChild(first); }, 2200);
  }

  // ---------- optional AI story band: video if present, else image, else nothing ----------
  const story = $('.story-wrap');
  if (story) {
    const exists = (u) => fetch(u, { method: 'HEAD' }).then((r) => r.ok && !(r.headers.get('content-type') || '').includes('text/html')).catch(() => false);
    (async () => {
      const box = $('.story', story);
      const wide = window.matchMedia('(min-width: 901px)').matches;
      const img = wide ? 'assets/img/story.webp' : 'assets/img/story-mobile.webp';
      if (!reduce && (await exists('assets/video/story.mp4'))) {
        box.innerHTML = `<video src="assets/video/story.mp4" poster="${img}" muted loop playsinline autoplay aria-hidden="true"></video>`;
      } else if (await exists(img)) {
        box.innerHTML = `<img src="${img}" alt="A phone on a dark desk at night, a saved screenshot framed by lime viewfinder corners" loading="lazy" decoding="async">`;
      } else return;
      story.hidden = false;
      io.observe(box);
    })();
  }

  // ---------- waitlist -> /api/waitlist -> Google Sheet ----------
  const flashEl = $('.flash');
  const joined = () => {
    $$('.wl-form-wrap').forEach((n) => (n.hidden = true));
    $$('.wl-done').forEach((n) => (n.hidden = false));
  };
  try { if (localStorage.getItem('shotr-joined')) joined(); } catch (e) { /* storage blocked */ }
  $$('form.wl').forEach((form) => {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      const input = $('input[type=email]', form), btn = $('button', form), label = btn.textContent;
      btn.disabled = true; btn.textContent = 'Joining…';
      fetch('/api/waitlist', {
        method: 'POST', headers: { 'content-type': 'application/json' },
        body: JSON.stringify({ email: input.value, source: form.dataset.source || 'landing', referrer: document.referrer }),
      }).then((r) => {
        if (!r.ok) throw new Error('bad');
        try { localStorage.setItem('shotr-joined', '1'); } catch (e) { /* ignore */ }
        if (!reduce && flashEl) { flashEl.classList.remove('go'); void flashEl.offsetWidth; flashEl.classList.add('go'); }
        joined();
      }).catch(() => {
        btn.disabled = false; btn.textContent = label;
        input.setCustomValidity('Could not join right now. Try again.'); input.reportValidity();
        setTimeout(() => input.setCustomValidity(''), 3000);
      });
    });
  });
})();
