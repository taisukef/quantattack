import { pal, sspr, print, max, min, sfx, btnp } from "../p8/p8.js";
import { draw_rounded_box } from "../lib/helpers.js";

//require("lib/high_score")

/*
local menu_item = new_class()

function menu_item._init(_ENV, _target_cart, _target_state, _sx, _sy, _width, _height, _cart_load_param, _label,
                         _description,
                         _high_score_slot)
  target_cart, target_state, sx, sy, width, height, cart_load_param, label, description, high_score =
  _target_cart, _target_state ~= "" and _target_state or nil, _sx, _sy, _width, _height, _cart_load_param, _label,
      _description,
      _high_score_slot and high_score_class(_high_score_slot):get()
end

menu_class = new_class()
*/

const menu_item = (ar) => {
  const names = ["target_cart", "target_state", "sx", "sy", "width", "height", "cart_load_param", "label", "description", "high_score"];
  const nnames = ["sx", "sy", "width", "height"];
  const res = {};
  for (let i = 0; i < ar.length; i++) {
    const name = names[i];
    res[name] = nnames.includes(name) ? parseInt(ar[i]) : ar[i];
  }
  return res;
};

export class Menu {
  constructor(items_string, previous_state) {
    this.items = [];
    for (const each of items_string.split("|")) {
      this.items.push(menu_item(each.split(",")));
    }
    this.active_item_index = 0;
    this.previous_state = previous_state;
    this.stale = false;
  }

  update() {
    /*
    if cart_to_load then
      if cart_load_delay > 0 then
        cart_load_delay = cart_load_delay - 1
      else
        jump(cart_to_load, nil, cart_load_param)
      end
    else
    */

    if (btnp(0)) { // left
      sfx(8);

      this.active_item_index = max(this.active_item_index - 1, 0);
    } else if (btnp(1)) { // right
      sfx(8);

      this.active_item_index = min(this.active_item_index + 1, this.items.length - 1);
    } else if (btnp(5)) { // x
      sfx(15);

      const selected_menu_item = this.items[this.active_item_index];
      if (selected_menu_item.target_state) {
        this.stale = true;
        return selected_menu_item.target_state;
      } else {
        console.log("cart to load:", selected_menu_item.target_cart);
        /*
        cart_to_load = selected_menu_item.target_cart
        cart_load_param = selected_menu_item.cart_load_param
        cart_load_delay = 30
        */
      }
    } else if (btnp(4)) { // c
      sfx(8);

      return this.previous_state;
    }
  }

  draw(left, top) {
    let sx = left;

    for (let i = 0; i < this.items.length; i++) {
      const each = this.items[i];
      if (i == this.active_item_index) {
        this.print_centered(each.label, 62, top - 16, 10);
        this.print_centered(each.description, 62, top - 8, 7);

        draw_rounded_box(sx - 2, top - 2, sx + each.width + 1, top + each.height + 1, this.stale ? 6 : 12);
        //print_centered(each.high_score and 'hi score: ' .. tostr(each.high_score, 0x2), 62, top + 23, 7)

        if (this.stale) {
          pal(7, 6);
        }
      } else {
        pal(7, 13)
      }

      sspr(each.sx, each.sy, each.width, 16, sx, top);

      pal();

      sx += each.width + 3;
    }
  }

  print_centered(text, center_x, center_y, col) {
    if (text) {
      print(text, center_x - text.length * 2 + 1, center_y - 2, col);
    }
  };
};
