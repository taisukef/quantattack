import { sspr, cls, flr, pal, btnp, sfx } from "./p8/p8.js";
import { render_plasma } from "./title/plasma.js";
import { draw_rounded_box, print_outlined } from "./lib/helpers.js";
import { Menu } from "./title/menu.js";

let title_state = ":logo_slidein";
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
const level_menu = new Menu(
  "quantattack_vs_qpu,,48,80,19,7,3|quantattack_vs_qpu,,72,80,27,7,2|quantattack_vs_qpu,,104,80,19,7,1",
  ":main_menu"
);

const fadepalette = [
  [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  [1, 1, 129, 129, 129, 129, 129, 129, 129, 129, 0, 0, 0, 0, 0],
  [2, 2, 2, 130, 130, 130, 130, 130, 128, 128, 128, 128, 128, 0, 0],
  [3, 3, 3, 131, 131, 131, 131, 129, 129, 129, 129, 129, 0, 0, 0],
  [4, 4, 132, 132, 132, 132, 132, 132, 130, 128, 128, 128, 128, 0, 0],
  [5, 5, 133, 133, 133, 133, 130, 130, 128, 128, 128, 128, 128, 0, 0],
  [6, 6, 134, 13, 13, 13, 141, 5, 5, 5, 133, 130, 128, 128, 0],
  [7, 6, 6, 6, 134, 134, 134, 134, 5, 5, 5, 133, 130, 128, 0],
  [8, 8, 136, 136, 136, 136, 132, 132, 132, 130, 128, 128, 128, 128, 0],
  [9, 9, 9, 4, 4, 4, 4, 132, 132, 132, 128, 128, 128, 128, 0],
  [10, 10, 138, 138, 138, 4, 4, 4, 132, 132, 133, 128, 128, 128, 0],
  [11, 139, 139, 139, 139, 3, 3, 3, 3, 129, 129, 129, 0, 0, 0],
  [12, 12, 12, 140, 140, 140, 140, 131, 131, 131, 1, 129, 129, 129, 0],
  [13, 13, 141, 141, 5, 5, 5, 133, 133, 130, 129, 129, 128, 128, 0],
  [14, 14, 14, 134, 134, 141, 141, 2, 2, 133, 130, 130, 128, 128, 0],
  [15, 143, 143, 134, 134, 134, 134, 5, 5, 5, 133, 133, 128, 128, 0],
];

const fadein = (i) => {
  const index = flr(15 - i);

  for (let c = 0; c <= 15; c++) {
    if (index < 0) {
      pal(c, c);
    } else {
      pal(c, fadepalette[c][index - 1]);
    }
  }
};

const update60 = () => {
  if (title_state == ":board_fadein") {
    //demo_game.update()
  } else if (title_state == ":demo") {
    //demo_game.update()
    update_title_logo_bounce()

    if (btnp(5)) { // x でタイトルへ進む
      sfx(15);
      title_state = ":main_menu";
    }
  } else if (title_state == ":main_menu") {
    if (main_menu._active_item_index == 4) {
      level_menu.stale = true;
    }

    main_menu.stale = false;
    title_state = main_menu.update() ?? title_state;
  } else if (title_state == ":level_menu") {
    level_menu.stale = false;
    title_state = level_menu.update() ?? title_state;
  }
  
  tick++;
};

const draw = () => {
  cls();
  render_plasma();

  if (title_state == ":logo_slidein") {
    sspr(0, 64, 128, 16, 0, tick);

    if (tick > 24) {
      title_state = ":board_fadein";
    }
  } else if (title_state == ":board_fadein") {
    sspr(0, 64, 128, 16, 0, 24);

    if (tick <= 90) {
      fadein((tick - 26) / 3);
    }
    //demo_game.render()
    pal();

    if (tick > 90) {
      title_state = ":demo";
    }
  } else {
    sspr(0, 64, 128, 16, 0, 24 + title_logo_bounce_screen_dy);

    //demo_game.render()

    if (title_state == ":demo") {
      // X start を表示
      if (tick % 60 < 30) {
        print_outlined("x start", 50, 50, 1, 10);
      }
    } else { // ":main_menu" or ":level_menu"
      // メニューのウィンドウを表示
      draw_rounded_box(1, 46, 125, 108, 0, 0); // ふちどり
      draw_rounded_box(2, 47, 124, 107, 12, 12); // 枠線
      draw_rounded_box(4, 49, 122, 105, 1, 1); // 本体

      // メニューを表示
      main_menu.draw(8, 72);

      // レベル選択メニューを表示
      if (main_menu._active_item_index == 3 || title_state == ":level_menu") {
        level_menu.draw(27, 93);
      }
    }
  }
};

setInterval(() => {
  update60();
  cls();
  draw();
}, 1000 / 30);
