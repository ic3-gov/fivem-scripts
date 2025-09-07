const banner = document.getElementById('banner');
const inner = document.getElementById('banner-inner');
const systemEl = document.getElementById('system');
const titleEl = document.getElementById('title');
const marquee = document.getElementById('marquee');
const marqueeText = document.getElementById('marquee-text');
const audioEl = document.getElementById('eas-audio');

let hideTimeout = null;
let animFrame = null;
let resizeObs = null;


function px(n){ return `${n|0}px`; }
function stopAnimation(){ if (animFrame) cancelAnimationFrame(animFrame); animFrame = null; }

function normalizeColor(c) {
  if (!c) return null;
  c = String(c).trim();
  if (/^#/.test(c) || /^[a-zA-Z]+$/.test(c)) return c;
  c = c.replace(/^0x/i, '');
  if (/^[0-9a-fA-F]{8}$/.test(c)) {
    const aa = c.slice(0, 2), rr = c.slice(2, 4), gg = c.slice(4, 6), bb = c.slice(6, 8);
    return aa.toLowerCase() === 'ff' ? `#${rr}${gg}${bb}` : `#${rr}${gg}${bb}${aa}`;
  }
  if (/^[0-9a-fA-F]{6}$/.test(c)) return `#${c}`;
  if (/^[0-9a-fA-F]{3}$/.test(c)) return `#${c}`;
  return c;
}

function runMarqueeRestart(speed, restartMode, getTextWidth) {
  stopAnimation();

  let pps = Math.max(20, speed|0);
  let containerW = marquee.clientWidth;
  let textW = getTextWidth();
  let x = containerW + 2;
  let last = performance.now();

  const shouldRestart = (xVal) => {
    if (restartMode === 'edge') return xVal <= 0;
    return xVal <= -textW;
  };

  function step(t) {
    const dt = (t - last) / 1000; last = t;
    x -= pps * dt;

    if (shouldRestart(x)) {
      containerW = marquee.clientWidth;
      textW = getTextWidth();
      x = containerW + 2;
    }

    marqueeText.style.transform = `translateX(${x}px)`;
    animFrame = requestAnimationFrame(step);
  }

  animFrame = requestAnimationFrame(step);
}

function showAlert(data){
  banner.style.height = px(data.cfg.height || 160);
  banner.style.background = normalizeColor(data.cfg.bg) || '#b30000';
  inner.style.borderBottomColor = normalizeColor(data.cfg.border) || '#ffeb3b';

  const txtColor = normalizeColor(data.cfg.color) || '#fff';
  const font     = data.cfg.font || 'Montserrat, Arial, sans-serif';
  const titleSz  = px(data.cfg.size || 28);
  const msgSz    = px((data.cfg.size || 28) + 2);

  systemEl.textContent = data.cfg.header || 'EMERGENCY ALERT SYSTEM';
  systemEl.style.color = 'gray';
  systemEl.style.fontFamily = font;

  titleEl.style.color = txtColor;
  titleEl.style.fontFamily = font;
  titleEl.style.fontSize = titleSz;
  titleEl.style.marginTop = px(data.cfg.headerGap || 4);
  titleEl.textContent = data.title || 'Emergency Alert';

  marqueeText.style.color = txtColor;
  marqueeText.style.fontFamily = font;
  marqueeText.style.fontSize = msgSz;
  const text = (data.text || '').replace(/\s+/g, ' ').trim() || ' ';
  marqueeText.textContent = text;

  banner.style.display = 'flex';

  const CLIP_SECONDS = 21;
  const durationSec = parseInt(data.duration) || 20;
  audioEl.loop = durationSec > CLIP_SECONDS;
  audioEl.volume = Math.max(0, Math.min(1, data.volume ?? 0.8));
  audioEl.currentTime = 0;
  try { audioEl.load(); } catch(_) {}
  audioEl.play().catch(()=>{});

  const getTextWidth = () => marqueeText.getBoundingClientRect().width;
  runMarqueeRestart(data.cfg.speed || 120, (data.cfg.restartMode || 'clear'), getTextWidth);

  if (resizeObs) { resizeObs.disconnect(); resizeObs = null; }
  resizeObs = new ResizeObserver(() => {
    stopAnimation();
    runMarqueeRestart(data.cfg.speed || 120, (data.cfg.restartMode || 'clear'), getTextWidth);
  });
  resizeObs.observe(marquee);

  if (hideTimeout) clearTimeout(hideTimeout);
  hideTimeout = setTimeout(hideAlert, Math.max(3000, durationSec * 1000));
}

function hideAlert(){
  stopAnimation();
  if (resizeObs) { resizeObs.disconnect(); resizeObs = null; }

  try {
    audioEl.loop = false;
    audioEl.pause();
    audioEl.currentTime = 0;
  } catch(_) {}

  banner.style.display = 'none';
  if (hideTimeout) clearTimeout(hideTimeout);
  hideTimeout = null;
}

window.addEventListener('message', (e) => {
  const data = e.data;
  if (!data || e.data.action !== 'show') return;
  try { showAlert(data); } catch(_) {}
});
