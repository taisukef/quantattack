import { sspr, cls } from "./p8/p8.js";
import { render_plasma } from "./title/plasma.js";
import { draw_rounded_box, print_outlined } from "./lib/helpers.js";
import { Menu } from "./title/menu.js";

let tick = 0;

let title_logo_bounce_speed = 0;
let title_logo_bounce_screen_dy = 0;

const bounce_title_logo = () => {
  title_logo_bounce_screen_dy = 0;
  title_logo_bounce_speed = -5;
};

const update_title_logo_bounce = () => {
  if (title_logo_bounce_speed != 0) {
    title_logo_bounce_speed = title_logo_bounce_speed + 0.9;
    title_logo_bounce_screen_dy = title_logo_bounce_screen_dy + title_logo_bounce_speed;

    if (title_logo_bounce_screen_dy > 0) {
      title_logo_bounce_screen_dy = 0;
      title_logo_bounce_speed = -title_logo_bounce_speed;
    }
  }
};

bounce_title_logo();

const main_menu = new Menu(
  "quantattack_tutorial,,32,48,16,16,,tutorial,learn how to play|quantattack_endless,,64,48,16,16,,endless,play as long as you can, 1|quantattack_rush,,48,48,16,16,,rush,play for 2 minutes,0|,:level_menu,80,48,16,16,,vs qpu,defeat the qpu|quantattack_qpu_vs_qpu,,96,48,16,16,,qpu vs qpu,watch qpu vs qpu|quantattack_vs_human,,112,48,16,16,,vs human,player1 vs player2",
  ":demo"
);

setInterval(() => {
  cls();
  render_plasma();
  sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy)

  draw_rounded_box(1, 46, 125, 108, 0, 0); // ふちどり
  draw_rounded_box(2, 47, 124, 107, 12, 12); // 枠線
  draw_rounded_box(4, 49, 122, 105, 1, 1); // 本体
  
  main_menu.update();  
  main_menu.draw(8, 72);

  /*
  if (tick % 60 < 30) {
    print_outlined("x start", 50, 50, 1, 10);
  }
  */

  update_title_logo_bounce();
  tick++;
}, 1000 / 30);
