// Genera los íconos PNG de ORIGEN replicando el favicon oficial
// (fondo crema + círculo negro sólido + semilla verde), sin dependencias.
const fs = require("fs");
const path = require("path");
const zlib = require("zlib");
const OUT = path.resolve(__dirname, "..", "assets");

// ---- PNG encoder (RGBA) ----
const crcTable = (() => { const t = []; for (let n = 0; n < 256; n++) { let c = n; for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1; t[n] = c >>> 0; } return t; })();
const crc32 = b => { let c = 0xffffffff; for (let i = 0; i < b.length; i++) c = crcTable[(c ^ b[i]) & 0xff] ^ (c >>> 8); return (c ^ 0xffffffff) >>> 0; };
function chunk(type, data) { const len = Buffer.alloc(4); len.writeUInt32BE(data.length, 0); const t = Buffer.from(type, "ascii"); const crc = Buffer.alloc(4); crc.writeUInt32BE(crc32(Buffer.concat([t, data])), 0); return Buffer.concat([len, t, data, crc]); }
function png(w, h, rgba) {
  const sig = Buffer.from([137, 80, 78, 71, 13, 10, 26, 10]);
  const ihdr = Buffer.alloc(13); ihdr.writeUInt32BE(w, 0); ihdr.writeUInt32BE(h, 4); ihdr[8] = 8; ihdr[9] = 6;
  const raw = Buffer.alloc((w * 4 + 1) * h);
  for (let y = 0; y < h; y++) { raw[y * (w * 4 + 1)] = 0; rgba.copy(raw, y * (w * 4 + 1) + 1, y * w * 4, (y + 1) * w * 4); }
  return Buffer.concat([sig, chunk("IHDR", ihdr), chunk("IDAT", zlib.deflateSync(raw, { level: 9 })), chunk("IEND", Buffer.alloc(0))]);
}

const hex = h => [parseInt(h.slice(1, 3), 16), parseInt(h.slice(3, 5), 16), parseInt(h.slice(5, 7), 16)];
const CREAM = hex("#F6F1E7"), INK = hex("#000000"), GREEN = hex("#5EBC66");

// Geometría tomada del favicon oficial (espacio 256, escala fullbleed 1.78).
const CX = 128, CY = 128, R = 89;              // círculo negro
const SEED = { cx: 122.3, cy: 110.0, r: 59.63 }; // semilla (medio disco)
const CHORD_MID = { x: 122.3, y: 110.0 };
const N = { x: -0.2789, y: 0.9602 };           // normal hacia el lado de la semilla (abajo-izq)

function drawIcon(S) {
  const buf = Buffer.alloc(S * S * 4);
  const k = S / 256; // escala
  for (let y = 0; y < S; y++) for (let x = 0; x < S; x++) {
    const px = x / k, py = y / k; // a espacio 256
    let c = CREAM;
    const dC = Math.hypot(px - CX, py - CY);
    if (dC <= R) {
      c = INK;
      const dS = Math.hypot(px - SEED.cx, py - SEED.cy);
      const side = (px - CHORD_MID.x) * N.x + (py - CHORD_MID.y) * N.y;
      if (dS <= SEED.r && side >= 0) c = GREEN; // semilla verde (medio disco)
    }
    const i = (y * S + x) * 4;
    buf[i] = c[0]; buf[i + 1] = c[1]; buf[i + 2] = c[2]; buf[i + 3] = 255;
  }
  return png(S, S, buf);
}

[192, 512, 180].forEach(S => {
  const name = S === 180 ? "apple-touch-icon-180.png" : `icon-${S}.png`;
  fs.writeFileSync(path.join(OUT, name), drawIcon(S));
  console.log("ok", name);
});
