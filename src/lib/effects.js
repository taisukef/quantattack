import { print, spr, cursor, rnd, circfill, atan2, cos, sin, sqrt, rectfill, t, fillp, sfx, ceil_rnd } from "../p8/p8.js";
import { draw_rounded_box } from "./helpers.js";

export class EffectSet {
  constructor() {
    this.all = [];
  }
  add(obj) {
    this.all.push(obj);
  }
  del(obj) {
    const idx = this.all.indexOf(obj);
    if (idx !== -1) {
      this.all.splice(idx, 1);
    }
  }
  update_all() {
    this.all.forEach(each => {
      this.update(each);
    });
  }
  render_all() {
    this.all.forEach(each => {
      this.render(each);
    });
  }
}

// 各種エフェクト

// bubbles: 同時消しまたは連鎖の数を表示

export class Bubbles extends EffectSet {
  // バブルを作る
  create(bubble_type, count, coord) {
    this.add({
      type: bubble_type,
      count: count,
      x: coord[0],
      y: coord[1] - 8,
      tick: 0,
    });
  }
  update(obj) {
    if (obj.tick > 40) {
      this.del(obj);
    } else {
      if (obj.tick < 30) {
        obj.y = obj.y - 0.2;
      }
      obj.tick++;
    }
  }
  render(obj) {
    if (obj.type == "combo") {
      draw_rounded_box(obj.x - 1, obj.y + 1, obj.x + 7, obj.y + 9, 5, 5);
      draw_rounded_box(obj.x - 1, obj.y, obj.x + 7, obj.y + 8, 7, 8);

      cursor(obj.x + 2, obj.y + 2);
    } else {
      const rbox_dx = obj.count < 10 ? 0 : -2;

      draw_rounded_box(obj.x + rbox_dx - 2, obj.y + 1, obj.x - rbox_dx + 8, obj.y + 9, 5, 5);
      draw_rounded_box(obj.x + rbox_dx - 2, obj.y, obj.x - rbox_dx + 8, obj.y + 8, 7, 3);

      spr(96, obj.x + rbox_dx, obj.y - 1); // the "x" part in "x5"

      cursor(obj.x + rbox_dx + 4, obj.y + 2);
    }
    
    print(obj.count, 10);
  }
}

// ions: 攻撃または相殺の時に表示するイオン球エフェクト

export class Ions extends EffectSet {
  constructor(particles) {
    super();
    this.particles = particles;
  }
  // イオン球エフェクトを作る
  //
  // 例: (64, 64) から (10, 10) へ青色 (デフォルト) のイオン球を飛ばす
  // ions.create([64, 64], [10, 10], ions_callback)
  //
  create(from, target, callback, ion_color = 12) {
    this.add({
      fromobj_x: from[0],
      fromobj_y: from[1],
      target,
      callback,
      color: ion_color,
      tick: 0,
    });
    sfx(20);
  }
  // イオン球の位置等を更新
  update(obj) {
    const quadratic_bezier = (from, mid, to) => {
      const t = obj.tick / 60;
      return (1 - t) * (1 - t) * from + 2 * (1 - t) * t * mid + t * t * to;
    };

    if (obj.tick == 60) {
      if (obj.callback) obj.callback(obj.target);
      this.del(obj);
    }
    
    obj.x = quadratic_bezier(obj.fromobj_x, obj.fromobj_x > 64 ? obj.fromobj_x + 60 : obj.fromobj_x - 60, obj.target[0]);
    obj.y = quadratic_bezier(obj.fromobj_y, obj.fromobj_y + 40, obj.target[1]);
    obj.tick++;

    // しっぽを追加
    if (ceil_rnd(10) > 7) {
      this.particles.create(
        [obj.x, obj.y],
        "3,2," + obj.color + "," + obj.color + ",0,0,0,0,20"
      )
    }
  }

  // イオン球を描画
  render(obj) {
    fillp(23130.5);
    circfill(obj.x, obj.y, 8 + 2 * sin(t()), obj.color);
    fillp();
    circfill(obj.x, obj.y, 6 + 2 * sin(1.5 * t()), obj.color);
    circfill(obj.x, obj.y, 5 + sin(2.5 * t()), 7);
  }
}

// パーティクルを表示
export class Particles extends EffectSet {
  // パーティクルの集合を作る
  create(coord, data) {
    const data1 = data.split("|");
    const names = [
      "radius", "end_radius", "color", "color_fade", "dx", "dy", "ddx", "ddy", "max_tick"
    ];
    for (const data2 of data1) {
      const d = data2.split(",");
      const obj = {
        x: coord[0],
        y: coord[1],
      };
      for (let i = 0; i < names.length; i++) {
        const name = names[i];
        const v = d[i];
        obj[name] = v == "" ? v : parseInt(v);
      }
      if (obj.dx == "") obj.dx = rnd(2) - 1;
      if (obj.dy == "") obj.dy = rnd(2) - 1;
      obj.tick = 0;
      obj.max_tick += rnd(10);
      this.add(obj);
    }
  }
  // パーティクルの位置等を更新
  update(obj) {
    if (obj.tick > obj.max_tick) {
      this.del(obj);
    } else {
      if (obj.tick > obj.max_tick * .5) {
        obj.color = obj.color_fade;
        obj.radius = obj.end_radius;
      }
      obj.x = obj.x + obj.dx;
      obj.y = obj.y + obj.dy;
      obj.dx = obj.dx + obj.ddx;
      obj.dy = obj.dy + obj.ddy;
      obj.tick++;
    }
  }
  // パーティクルを描画
  render(obj) {
    circfill(obj.x, obj.y, obj.radius, obj.color);
  }
}

// 背景の波紋を描画するクラス
export class Ripple extends EffectSet {
  constructor(slow, freeze) {
    super();
    this.slow = slow;
    this.freeze = freeze;
  }
  create() {
    this.add({
      t1: 0,
      t2: 0,
      tick: 0,
    });
  }
  // 波紋の状態を更新
  update(obj) {
    const slow = this.slow || this.freeze;
    obj.t1 = obj.t1 - 1 / (slow ? 3000 : 1500);
    obj.t2 = obj.t2 - 1 / (slow ? 300 : 150);
    obj.tick++;
  }
  // 波紋を描画
  render(obj) {
    for (let i = -5; i <= 5; i++) {
      for (let j = -5; j <= 5; j++) {
        const ang = atan2(i, j); 
        const d = sqrt(i * i + j * j);
        const r = 2 + 2 * sin(d / 4 + obj.t2);
        circfill(
          64 + 12 * d * cos(ang + obj.t1),
          64 + 12 * d * sin(ang + obj.t1) - 3 * r,
          r,
          ((this.slow || this.freeze) && r > 3 && obj.tick % 2 == 0) ? (this.slow ? 13 : 12) : 1
        )
      }
    }
  }
}

// sash.create("text,text_color,background_color", slideout_callback) 新しい sash を作る (シングルトン)
// text: 表示するテキスト
//   - text_color: テキストの色
//   - background_color: sash の背景色
//   - slideout_callback: sash が右端から消えた時に呼ぶコールバック

export class Sash extends EffectSet {
  create(properties, slideout_callback) {
    this.all.length = 0; // singleton
    const p = properties.split(",");
    const text = p[0];
    this.add({
      text,
      text_color: p[1],
      background_color: p[2],
      background_height: 0,
      dh: 0.1,
      ddh: 0.2,
      slideout_callback,
      textobj_x: text.length * -4,
      text_dx: 5,
      text_ddx: -0.14,
      text_centerobj_x: 64 - text.length * 2,
      state: ":slidein",
    });
  }
  update(obj) {
    if (obj.state == ":slidein") {
      obj.background_height += obj.dh;
      obj.dh += obj.ddh;
      if (obj.background_height > 10) {
        obj.background_height = 10
      }

      if (obj.textobj_x < obj.text_centerobj_x) {
        obj.textobj_x += obj.text_dx;
        obj.text_dx += obj.text_ddx;
      }

      if (obj.textobj_x > obj.text_centerobj_x) {
        obj.textobj_x = obj.text_centerobj_x;
        obj.time_stop = t();
        obj.state = ":stop";
      }
    }
    if (obj.state == ":stop") {
      if (t() - obj.time_stop > 1) {
        obj.dh = -0.1;
        obj.ddh = -0.2;
        obj.text_dx = 3;
        obj.text_ddx = 0;
        obj.state = ":slideout";
      }
    }
    if (obj.state == ":slideout") {
      obj.background_height += obj.dh;
      obj.dh += obj.ddh;
      obj.textobj_x += obj.text_dx;
      obj.text_dx += obj.text_ddx;

      if (obj.textobj_x > 127) {
        if (obj.slideout_callback) {
          obj.slideout_callback();
        }

        obj.state = ":finished";
      }
    }
  }

  render(obj) {
    if (obj.background_height > 0) {
      rectfill(0, 64 - obj.background_height / 2, 127, 64 + obj.background_height / 2, obj.background_color);
      print(obj.text, obj.textobj_x, 64 - 2, obj.text_color);
    }
  }
}
