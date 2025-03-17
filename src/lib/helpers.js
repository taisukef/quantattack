import { flr, rnd, line, rectfill, print } from "../p8/p8.js";

export const ceil_rnd = (num) => {
  return flr(rnd(num)) + 1;
};

export const draw_rounded_box = (x0, y0, x1, y1, border_color, fill_color) => {
  line(x0 + 1, y0, x1 - 1, y0, border_color);
  line(x1, y0 + 1, x1, y1 - 1, border_color);
  line(x1 - 1, y1, x0 + 1, y1, border_color);
  line(x0, y1 - 1, x0, y0 + 1, border_color);

  if (fill_color) {
    rectfill(x0 + 1, y0 + 1, x1 - 1, y1 - 1, fill_color);
  }
};

export const print_outlined = (str, x, y, color, border_color) => {
  if (border_color != 0) {
    for (let dx = -2; dx <= 2; dx++) {
      for (let dy = -2; dy <= 2; dy++) {
        print(str, x + dx, y + dy, 0);
      }
    }
  }
  for (let dx = -1; dx <= 1; dx++) {
    for (let dy = -1; dy <= 1; dy++) {
      print(str, x + dx, y + dy, border_color ?? 12);
    }
  }

  print(str, x, y, color);
};

