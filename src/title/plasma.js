import { flr, pset } from "../p8/p8.js";

let time = 0;
const colors = [0, 5, 12, 5, 12];

export const render_plasma = () => {
  const t = time / 12;
  const sint = Math.sin(t / 15) / 120;
  const cost = Math.cos(t / 17) / 180;

  for (let x = 0; x <= 31; x++) {
    for (let y = 0; y <= 31; y++) {
      let v = Math.sin(((x * sint) + y * cost) * 8 + t);
      v = flr((v * Math.cos(x / 53 + y / 57) + 1) * 2.5);
      pset(x << 2, y << 2, colors[v]);
    }
  }
  time += 0.05;
};
