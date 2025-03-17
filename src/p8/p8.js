import { palette } from "./palette.js";
import { font } from "./font.js";

export const flr = (n) => Math.floor(n);

export const rnd = (n) => Math.random() * n;
export const max = (n, m) => Math.max(n, m);
export const min = (n, m) => Math.min(n, m);

const PI2 = Math.PI * 2;
export const sin = (n) => Math.sin(n * PI2);
export const cos = (n) => Math.cos(n * PI2);

const canvas = document.createElement("canvas");
document.body.style.margin = 0;
document.body.appendChild(canvas);
const w = 1280;
canvas.width = w;
canvas.height = w;
canvas.style.width = "100vw";
canvas.style.height = "100vw";
const g = canvas.getContext("2d");
const dot = 10; // w / 128;

let spr = null;
let music = null;
const loadData = async () => {
  const data = await (await fetch("../data.p8")).text();
  const ss = data.split("\n");
  const s1 = [];
  let state = 0;
  for (const s of ss) {
    if (state == 0) {
      if (s == "__gfx__") {
        state = 1;
      }
    } else if (state == 1) {
      if (s == "__sfx__") {
        state = 2;
      } else {
        const buf = new Uint8Array(128);
        for (let i = 0; i < 128; i++) {
          buf[i] = parseInt(s[i], 16);
        }
        s1.push(buf);
      }
    }
  }
  spr = s1;
};
await loadData();

const toi = (n) => {
  if (typeof n == "string") return parseInt(n);
  return n;
};

export const sspr = (x, y, w, h, dx, dy) => {
  x = toi(x);
  y = toi(y);
  w = toi(w);
  h = toi(h);
  dx = toi(dx);
  dy = toi(dy);
  for (let i = 0; i < h; i++) {
    const buf = spr[y + i];
    for (let j = 0; j < w; j++) {
      const c = buf[x + j];
      if (c) pset(dx + j, dy + i, buf[x + j]);
    }
  }
};

let currentcolor = 0;
export const color = (n) => {
  currentcolor = n;
};

const currentpalette = [...palette];
export const pal = (c0, c1) => {
  if (c1 === undefined) {
    for (let i = 0; i < palette.length; i++) {
      currentpalette[i] = palette[i];
    }
  } else {
    currentpalette[c0] = palette[c1];
  }
};

export const pset = (x, y, c = currentcolor) => {
  g.fillStyle = currentpalette[c];
  g.fillRect(Math.floor(x) * dot, Math.floor(y) * dot, dot, dot);
  currentcolor = c;
};

export const rectfill = (x0, y0, x1, y1, col = currentcolor) => {
  const w = x1 - x0 + 1;
  const h = y1 - y0 + 1;
  for (let i = 0; i < h; i++) {
    for (let j = 0; j < w; j++) {
      pset(x0 + j, y0 + i, col);
    }
  }
};

let bkx1 = null;
let bky1 = null;
export const line = (x0, y0, x1, y1, color = currentcolor) => {
  if (y0 === undefined) {
    bkx1 = bky1 = null;
    currentcolor = x0;
    return;
  }
  if (y1 === undefined) {
    color = x1 ?? currentcolor;
    x1 = x0;
    y1 = y0;
    x0 = bkx1;
    y0 = bky1;
  }
  bkx1 = x1 = Math.floor(x1);
  bky1 = y1 = Math.floor(y1);
  if (x0 === null) return;
  x0 = Math.floor(x0);
  y0 = Math.floor(y0);
  const dx = Math.abs(x1 - x0);
  const dy = Math.abs(y1 - y0);
  const sx = x0 < x1 ? 1 : -1;
  const sy = y0 < y1 ? 1 : -1;
  let err = dx - dy;
  for (;;) {
    pset(x0, y0, color);
    if (x0 == x1 && y0 == y1) break;
    const e2 = 2 * err;
    if (e2 > -dy) {
      err = err - dy;
      x0 = x0 + sx;
    }
    if (e2 < dx) {
      err = err + dx;
      y0 = y0 + sy;
    }
  }
};

let tx = 1;
let ty = 1;

const putchar = (ch, x, y, color) => {
  if (y === undefined) {
    color = x;
    x = tx;
    y = ty;
  }
  if (ch == "\n") {
    tx = 1;
    ty += 6;
    return;
  }
  const code = ch.charCodeAt(0);
  if (code < 0x20 || code > 0x7f) return;
  const offset = (code - 0x20) * 4;
  for (let i = 0; i < 5; i++) {
    for (let j = 0; j < 3; j++) {
      if (font[i][offset + j] == "1") {
        pset(x + j, y + i, color);
      }
    }
  }
  tx = x + 4;
  ty = y;
};

export const print = (text, x, y, color = currentcolor) => {
  if (y === undefined) {
    color = x;
    x = tx;
    y = ty;
  } else {
    tx = x;
    ty = y;
  }
  for (const c of text) {
    putchar(c, color);
  }
  putchar("\n");
};

export const cls = (c = 0) => {
  rectfill(0, 0, 128, 128, c);
};

cls();

export const sfx = (n) => {
  console.log("sfx", n);
};

const pressed = [];
document.body.onkeydown = (e) => {
  //console.log(e.key);
  if (e.key == "ArrowLeft") {
    pressed[0] = true;
  } else if (e.key == "ArrowRight") {
    pressed[1] = true;
  } else if (e.key == "c") {
    pressed[4] = true;
  } else if (e.key == "x") {
    pressed[5] = true;
  }
};

export const btnp = (n) => {
  if (pressed[n]) {
    pressed[n] = false;
    return true;
  }
  return false;
};
