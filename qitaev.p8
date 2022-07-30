pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
colors = {
  ["dark_purple"] = 2,
  ["dark_green"] = 3,
  ["dark_grey"] = 5,
  ["light_grey"] = 6,
  ["white"] = 7,
  ["red"] = 8,
  ["orange"] = 9,
  ["yellow"] = 10,
  ["blue"] = 12,
}

dropping_particle = {
  all = {},

  create = function(self, x, y, init_size, color)
    local p = {}
    local left = false

    if flr(rnd(2)) == 0 then
      left = true
    end

    p.x = x
    p.y = y
    p.color = color
    p.width = init_size
    p.tick = 0
    p.max_tick = 20 + rnd(10)
    p.dx = (rnd(.8)) * .4
    p.dy = rnd(.05)
    p.ddy = .02

    if (left) then
      p.dx *= -1
    end

    add(dropping_particle.all, p)

    return p
  end,

  update = function(self)
    foreach(dropping_particle.all, function(p)
      if (p.tick > p.max_tick) then
        del(dropping_particle.all, p)
      end
      if (p.tick > p.max_tick - 5) then
        p.color = colors.dark_grey
      end

      p.x = p.x + p.dx
      p.y = p.y + p.dy
      p.dy = p.dy + p.ddy
      p.tick = p.tick + 1
    end)
  end,

  draw = function(self)
    foreach(dropping_particle.all, function(p)
      circfill(p.x, p.y, p.width, p.color)
    end)
  end
}

gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next)
    include_next = include_next or false

    if include_next then
      if y + 1 > board.rows + board.next_row then
        return {}
      end
    else
      if y + 1 > board.rows then
        return {}
      end    
    end

    if (board:idle_gate_at(x, y).type == "h" and
        board:idle_gate_at(x, y + 1).type == "h") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y).type == "x" and
        board:idle_gate_at(x, y + 1).type == "x") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y).type == "y" and
        board:idle_gate_at(x, y + 1).type == "y") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y).type == "z" and
        board:idle_gate_at(x, y + 1).type == "z") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
      }
    end

    if (board:idle_gate_at(x, y).type == "z" and
        board:idle_gate_at(x, y + 1).type == "x") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.y() },
      }
    end

    if (board:idle_gate_at(x, y).type == "x" and
        board:idle_gate_at(x, y + 1).type == "z") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.y() },
      }
    end

    if (board:idle_gate_at(x, y).type == "s" and
        board:idle_gate_at(x, y + 1).type == "s") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.z() },
      }
    end

    if (board:idle_gate_at(x, y).type == "t" and
        board:idle_gate_at(x, y + 1).type == "t") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.s() },
      }
    end

    if include_next then
      if y + 2 > board.rows + board.next_row then
        return {}
      end       
    else
      if y + 2 > board.rows then
        return {}
      end    
    end

    if (board:idle_gate_at(x, y).type == "h" and
        board:idle_gate_at(x, y + 1).type == "x" and
        board:idle_gate_at(x, y + 2).type == "h") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.z() },
      }      
    end 

    if (board:idle_gate_at(x, y).type == "h" and
        board:idle_gate_at(x, y + 1).type == "z" and
        board:idle_gate_at(x, y + 2).type == "h") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.x() },
      }
    end 

    if (board:idle_gate_at(x, y).type == "s" and
        board:idle_gate_at(x, y + 1).type == "z" and
        board:idle_gate_at(x, y + 2).type == "s") then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = gate.i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = gate.z() },
      }      
    end 

    return {}
  end,
}

board = {
  cols = 6,
  rows = 12,
  next_row = 1,

  new = function(self, top, left)
    local b = {
      init = function(self, top, left)
        self.gate = {}
        self.top = top
        self.left = left
        self.cols = board.cols
        self.rows = board.rows
        self.next_row = board.next_row
        self.raised_dots = 0

        for x = 1, board.cols do
          self.gate[x] = {}
          for y = board.rows + board.next_row, 1, -1 do
            if y >= 5 then
              repeat
                self:set(x, y, self:_random_gate())
              until (#gate_reduction_rules:reduce(self, x, y, true) == 0)
            else
              self:set(x, y, gate.i())
            end
          end
        end
      end,

      idle_gate_at = function(self, x, y)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows + board.next_row)

        if self.gate[x][y]:is_idle() then
          return self.gate[x][y]
        else
          return gate.i()
        end
      end,

      set = function(self, x, y, gate)
        assert(x >= 1 and x <= board.cols)
        assert(y >= 1 and y <= board.rows + board.next_row)

        self.gate[x][y] = gate
      end,

      update = function(self)
        self:reduce()
        self:drop_gates()
        self:update_gates()
      end,

      draw = function(self)
        for bx = 1, board.cols do
          for by = board.rows + board.next_row, 1, -1 do
            local x = self.left + (bx - 1) * gate.size
            local y = self.top + (by - 1) * gate.size

            wire:draw(x, y - self.raised_dots)

            local gate = self.gate[bx][by]
            if gate:is_swapping_with_left() then
              gate:draw(x + 4, y - self.raised_dots)
            elseif gate:is_swapping_with_right() then
              gate:draw(x - 4, y - self.raised_dots)
            else
              gate:draw(x, y - self.raised_dots)
            end

            if (by == board.rows + board.next_row) then
              spr(13, x, y - self.raised_dots)
            end
          end
        end
      end,

      swap = function(self, xl, xr, y)
        local left_gate = self.gate[xl][y]
        local right_gate = self.gate[xr][y]
        assert(left_gate ~= nil)
        assert(right_gate ~= nil)

        if not self:is_swappable(left_gate, right_gate) then
          return false
        end

        right_gate:swap_with_left()
        left_gate:swap_with_right()

        self:set(xl, y, right_gate)
        self:set(xr, y, left_gate)
      end,

      is_swappable = function(self, left_gate, right_gate)
        return (left_gate:is_idle() or left_gate:is_dropped()) and
                 (right_gate:is_idle() or right_gate:is_dropped())
      end,

      reduce = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            if self.gate[x][y]:is_idle() then
              reduction = gate_reduction_rules:reduce(self, x, y)
              for index, r in pairs(reduction) do
                self.gate[x + r.dx][y + r.dy]:replace_with(r.gate)
                -- self.gate[x][y + index - 1]:replace_with(gate)
              end
            end
          end
        end
      end,

      gates_in_action = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            if not self.gate[x][y]:is_idle() then
              add(gates, self.gate[x][y])
            end
          end
        end

        return gates
      end,

      gates_dropped_bottom = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self.gate[x][y]
            local gate_below = self.gate[x][y + 1]

            if (gate.type ~= "i" and
                gate:is_dropped() and
                gate.tick_drop == 0 and
                (gate_below == nil or (not gate_below:is_dropped()))) then
              gate.x = x
              gate.y = y
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      gates_changing_to_i = function(self)
        local gates = {}

        for x = 1, board.cols do
          for y = 1, board.rows do
            local gate = self.gate[x][y]

            if gate:is_changing_to_i() then
              gate.x = x
              gate.y = y
              add(gates, gate)
            end
          end
        end

        return gates
      end,

      drop_gates = function(self)
        for x = 1, board.cols do
          for y = board.rows - 1, 1, -1 do
            local ty = y
            local gate_below = self.gate[x][ty + 1]
            while (gate_below ~= nil and
                   self.gate[x][ty].type != "i" and
                   self.gate[x][ty]:is_idle() and
                   gate_below:is_idle() and
                   gate_below.type == "i") do
              self.gate[x][ty + 1] = self.gate[x][ty]
              self.gate[x][ty] = gate.i()
              ty += 1
              gate_below = self.gate[x][ty + 1]
            end

            if (ty > y) then
              self.gate[x][ty]:dropped()
            end
          end
        end
      end,

      insert_gates_at_bottom = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows + board.next_row - 1 do
            if y == 1 and self.gate[x][y].type ~= 'i' then
              self:game_over()
            else
              self.gate[x][y] = self.gate[x][y + 1]
            end
          end
        end

        for x = 1, board.cols do
          repeat
            self:set(x, board.rows + board.next_row, self:_random_gate())
            gate_reduction_rules:reduce(self, x, board.rows - 1, true)
          until (#gate_reduction_rules:reduce(self, x, board.rows, true) == 0)
        end
      end,

      update_gates = function(self)
        for x = 1, board.cols do
          for y = 1, board.rows do
            self.gate[x][y]:update()
          end
        end
      end,

      raise_one_dot = function(self)
        self.raised_dots += 1
        if self.raised_dots == 8 then
          self.raised_dots = 0
        end
      end,

      game_over = function(self)
        assert(false, "game over")
      end,

      -- private

      _random_gate = function(self)
        local non_i_gate = nil
        repeat
          non_i_gate = gate:new(gate.types[flr(rnd(#gate.types)) + 1])
        until non_i_gate.type ~= "i"

        return non_i_gate
      end,
    }

    b:init(top, left)

    return b
  end,
}

wire = {
  _sprite = 12,

  draw = function(self, x, y)
    spr(self._sprite, x, y)
  end,
}

gate = {
  types = {"h", "x", "y", "z", "s", "t", "i"},

  sprites = {
    ["idle"] = {
      ["h"] = 0,
      ["x"] = 1,
      ["y"] = 2,
      ["z"] = 3,
      ["s"] = 4,
      ["t"] = 5,
      ["i"] = 6,
    },
    ["dropped"] = {
      ["h"] = 16,
      ["x"] = 17,
      ["y"] = 18,
      ["z"] = 19,
      ["s"] = 20,
      ["t"] = 21,
    },
    ["jumping"] = {
      ["h"] = 48,
      ["x"] = 49,
      ["y"] = 50,
      ["z"] = 51,
      ["s"] = 52,
      ["t"] = 53,
    },
    ["falling"] = {
      ["h"] = 32,
      ["x"] = 33,
      ["y"] = 34,
      ["z"] = 35,
      ["s"] = 36,
      ["t"] = 37,
    },    
    ["match"] = {
      ["h"] = 48,
      ["x"] = 49,
      ["y"] = 50,
      ["z"] = 51,
      ["s"] = 52,
      ["t"] = 53,
    },
    ["match_left"] = {
      ["h"] = 6,
      ["x"] = 7,
      ["y"] = 8,
      ["z"] = 9,
      ["s"] = 10,
      ["t"] = 11,
    },
    ["match_middle"] = {
      ["h"] = 22,
      ["x"] = 23,
      ["y"] = 24,
      ["z"] = 25,
      ["s"] = 26,
      ["t"] = 27,
    },     
    ["match_right"] = {
      ["h"] = 38,
      ["x"] = 39,
      ["y"] = 40,
      ["z"] = 41,
      ["s"] = 42,
      ["t"] = 43,
    },    
  },

  size = 8,

  num_frames_swap = 4,
  num_frames_match = 60,

  new = function(self, type)
    return {
      type = type,
      replace_with_type = nil,
      _state = "idle",

      draw = function(self, x, y)
        if self.type == "i" then return end

        spr(self:_sprite(), x, y)
      end,

      replace_with = function(self, other)
        assert(self.type ~= "i")
        assert(other.type)

        if self._state != "idle" then
          return
        end

        self.replace_with_type = other.type
        self:change_state("match")
        self.tick_match = 0
      end,

      dropped = function(self)
        self:change_state("dropped")
      end,

      change_state = function(self, new_state)
        assert(new_state)

        self._state = new_state
      end,

      swap_with_left = function(self)
        self:change_state("swapping_with_left")
      end,

      swap_with_right = function(self)
        self:change_state("swapping_with_right")
      end,

      update = function(self)
        if self:is_idle() then
          return
        elseif self:is_swapping() then
          if self.tick_swap == nil then
            self.tick_swap = 0
          elseif self.tick_swap < gate.num_frames_swap then
            self.tick_swap += 1
          else
            self:change_state("idle")
          end
        elseif self:is_match() then
          if self.tick_match == nil then
            self.tick_match = 0
          elseif self.tick_match < gate.num_frames_match then
            self.tick_match += 1
          else
            self.type = self.replace_with_type
            self:change_state("idle")
          end
        elseif self:is_dropped() then
          if self.tick_drop == nil then
            self.tick_drop = 0
          else
            self.tick_drop += 1
            if self.tick_drop == 12 then
               self.tick_drop = nil
               self:change_state("idle")
            end
          end
        else
          assert(false, "we should never get here")
        end
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_swapping = function(self)
        return self:is_swapping_with_left() or self:is_swapping_with_right()
      end,

      is_swapping_with_left = function(self)
        return self._state == "swapping_with_left"
      end,

      is_swapping_with_right = function(self)
        return self._state == "swapping_with_right"
      end,

      is_match = function(self)
        return self._state == "match"
      end,

      is_dropped = function(self)
        return self._state == "dropped"
      end,

      is_changing_to_i = function(self)
        return self.tick_match == gate.num_frames_match - 1 and self.replace_with_type == "i"
      end,

      -- private

      _sprite = function(self)
        if self:is_idle() then
          return gate.sprites.idle[self.type]
        elseif self:is_swapping() then
          return gate.sprites.idle[self.type]
        elseif self:is_match() then
          local icon = self.tick_match % 12
          if icon == 0 or icon == 1 or icon == 2 then
            return gate.sprites.match_left[self.type]
          elseif icon == 3 or icon == 4 or icon == 5 then
            return gate.sprites.match_middle[self.type]
          elseif icon == 6 or icon == 7 or icon == 8 then
            return gate.sprites.match_right[self.type]
          elseif icon == 9 or icon == 10 or icon == 11 then
            return gate.sprites.match_middle[self.type]
          end
        elseif self:is_dropped() then
          if self.tick_drop < 5 then
            return gate.sprites.dropped[self.type]
          elseif self.tick_drop < 7 then
            return gate.sprites.jumping[self.type]
          elseif self.tick_drop < 11 then
            return gate.sprites.falling[self.type]
          end        
          return gate.sprites.dropped[self.type]
        else
          assert(false, "we should never get here")
        end
      end
    }
  end,
}

gate.x = function()
  return gate:new("x")
end
gate.y = function()
  return gate:new("y")
end
gate.z = function()
  return gate:new("z")
end
gate.s = function()
  return gate:new("s")
end
gate.i = function()
  return gate:new("i")
end

-- player's cursor class

player_cursor = {
  _sprites = {
    ["corner"] = 28,
    ["middle"] = 44
  },

  new = function(self, x, y, board)
    local c = {
      init = function(self, x, y, board)
        self.x = x
        self.y = y
        self.board = board
        self._color = colors.dark_green
        self._tick = 0
        self:_change_state("idle")
      end,

      move_left = function(self)
        if self.x == 1 then
          self:flash()
        else
          self.x -= 1
        end
      end,

      move_right = function(self)
        if self.x == board.cols - 1 then
          self:flash()
        else
          self.x += 1
        end
      end,

      move_up = function(self)
        if self.y == 1 then
          self:flash()
        else
          self.y -= 1
        end
      end,

      move_down = function(self)
        if self.y == board.rows then
          self:flash()
        else
          self.y += 1
        end
      end,

      flash = function(self)
        self:_change_state("flash")
      end,

      update = function(self)
        assert(self._tick >= 0 and self._tick < 30)

        -- tick == 0 ... 14: state -> "idle"
        if self._tick == 15 then
          self:_change_state("shrunk")
        end

        -- tick == 15 ... 29: state -> "shrunk"
        if self._tick == 29 then
          self:_change_state("idle")
        end

        self._tick += 1
        if self._tick == 30 then
          self._tick = 0
        end
      end,

      draw = function(self, raised_dots)
        -- top left
        local xtl = self.board.left + (self.x - 1) * gate.size - 5
        local ytl = self.board.top + (self.y - 1) * gate.size - 5

        -- top right
        local xtr = self.board.left + self.x * gate.size + 4
        local ytr = ytl

        -- bottom left
        local xbl = xtl
        local ybl = self.board.top + self.y * gate.size - 4

        -- bottom right
        local xbr = self.board.left + self.x * gate.size + 4
        local ybr = ybl

        -- top middle
        local xtm = self.board.left + (self.x - 1) * gate.size + 4
        local ytm = ytl

        -- bottom middle
        local xbm = self.board.left + (self.x - 1) * gate.size + 4
        local ybm = ybl

        if self:is_shrunk() then
          xtl += 1
          ytl += 1
          xtr -= 1
          ytr += 1
          xbl += 1
          ybl -= 1
          xbr -= 1
          ybr -= 1
          ytm += 1
          ybm -= 1
        end

        if self:is_flash() then
          pal(self._color, colors.red)
        end

        spr(player_cursor._sprites.corner, xtl, ytl - raised_dots)
        spr(player_cursor._sprites.corner, xtr, ytr - raised_dots, 1, 1, true, false)
        spr(player_cursor._sprites.corner, xbl, ybl - raised_dots, 1, 1, false, true)
        spr(player_cursor._sprites.corner, xbr, ybr - raised_dots, 1, 1, true, true)
        spr(player_cursor._sprites.middle, xtm, ytm - raised_dots)
        spr(player_cursor._sprites.middle, xbm, ybm - raised_dots, 1, 1, false, true)

        pal(self._color, self._color)
      end,

      is_idle = function(self)
        return self._state == "idle"
      end,

      is_flash = function(self)
        return self._state == "flash"
      end,

      is_shrunk = function(self)
        return self._state == "shrunk"
      end,

      -- private

      _change_state = function(self, new_state)
        assert(new_state)
        assert(new_state == "idle" or new_state == "shrunk" or new_state == "flash")

        if new_state == "idle" then
          assert(self._state == nil or self:is_shrunk() or self:is_flash())
        end
        if new_state == "shrunk" then
          assert(self:is_idle() or self:is_flash())
        end

        self._state = new_state
      end,
    }

    c:init(x, y, board)

    return c
  end,
}

game = {
  init = function(self)
    self.board = board:new(32, 3)
    self.player_cursor = player_cursor:new(1, 1, self.board)
    self.tick = 0
    self.num_raise_gates = 0
  end,

  update = function(self, board)
    self.tick += 1

    dropping_particle:update()

    if btnp(0) then
      self.player_cursor:move_left()
    end

    if btnp(1) then
      self.player_cursor:move_right()
    end

    if btnp(2) then
      self.player_cursor:move_up()
    end

    if btnp(3) then
      self.player_cursor:move_down()
    end

    if (btnp(4)) then
      local swapped = self.board:swap(self.player_cursor.x, self.player_cursor.x + 1, self.player_cursor.y)
      if swapped == false then
        self.player_cursor:flash()
      end
    end

    self.board:reduce()
    self.board:drop_gates()
    self.board:update_gates()

    foreach(self.board:gates_dropped_bottom(), function(each)
      local x = self.board.left + (each.x - 1) * gate.size
      local y = self.board.top + (each.y - 1) * gate.size

      dropping_particle:create(x + 1, y + 7, 0, colors.white)
      dropping_particle:create(x + 3, y + 7, 0, colors.white)
      dropping_particle:create(x + 5, y + 7, 0, colors.white)
    end)

    foreach(self.board:gates_changing_to_i(), function(each)
      for x = 0, 7 do
        for y = 0, 7 do
          if x % 3 == 0 and y % 3 == 0 then
            local px = self.board.left + (each.x - 1) * gate.size + x
            local py = self.board.top + (each.y - 1) * gate.size + y

            dropping_particle:create(px, py, 1, colors.blue)
            dropping_particle:create(px, py, 0, colors.dark_purple)
          end
        end
      end
    end)

    self.player_cursor:update()
    local left_gate = self.board.gate[self.player_cursor.x][self.player_cursor.y]
    local right_gate = self.board.gate[self.player_cursor.x + 1][self.player_cursor.y]
    if not self.board:is_swappable(left_gate, right_gate) then
      self.player_cursor:flash()
    end

    if self.tick == 30 then
      if #self.board:gates_in_action() == 0 then
        self.num_raise_gates += 1
        self.board:raise_one_dot()
        if self.num_raise_gates == 8 then
          self.num_raise_gates = 0
          self.board:insert_gates_at_bottom()
          self.player_cursor:move_up()
        end
      end

      self.tick = 0
    end
  end,

  draw_stats = function(self)
    cursor(0, 0)
    color(7)
    print("cpu: " .. stat(1) * 100)
    print("fps: " .. stat(7))
  end,

  draw = function(self)
    cls()

    self.board:draw()
    self.player_cursor:draw(self.board.raised_dots)
    self:draw_stats()
    dropping_particle:draw()
  end,    
}

function _init()
  game:init()
end

function _update60()
-- function _update()
  game:update()
end

function _draw()
  game:draw()
end
__gfx__
06666600006660000666660006666600044444000222220007ccc70000c7c00007ccc700077777000c7777000777770000050000505050500000000000000000
616661600661660061666160611111604466664026666620c7ccc7c00cc7cc00cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000050000050505050000000000000000
616661606661666066161660666616604644444022262220c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000050000505050500000000000000000
611111606111116066616660666166604466644022262220c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000050000050505050000000000000000
616661606661666066616660661666604444464022262220c7ccc7c0ccc7ccc0ccc7ccc0c77777c0c7777cc0ccc7ccc000050000505050500000000000000000
616661600661660066616660611111604666644022262220ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc000050000050505050000000000000000
0666660000666000066666000666660004444400022222000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc0000050000505050500000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050000050505050000000000000000
0666660000666000066666000666660004444400022222000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc0000000000000000000000000000000000
666666600666660066666660666666604444444022222220c7ccc7c00cc7cc00c7ccc7c0c77777c0cc7777c0c77777c000000000000000000000000000000000
666666606666666066666660666666604444444022222220c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000333330000000000000000000000000
616661606661666061666160611111604466664026666620c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000377730000000000000000000000000
616661606661666066161660666616604644444022262220c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000373330000000000000000000000000
611111600111110066616660661166604466664022262220c7ccc7c00cc7cc00ccc7ccc0c77777c0c7777cc0ccc7ccc000373000000000000000000000000000
0116110000616000066166000111110006666600022622000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc0000333000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0166610000616000016661000111110004666600066666000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc0000000000000000000000000000000000
616661600661660066161660666616604644444022262220ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc000000000000000000000000000000000
611111606111116066616660666166604466644022262220c7ccc7c0ccc7ccc0c7ccc7c0c77777c0cc7777c0c77777c033333330000000000000000000000000
616661606661666066616660661666604444464022262220c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc037777730000000000000000000000000
616661606661666066616660611111604666644022262220c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc033373330000000000000000000000000
666666600666660066666660666666604444444022222220c7ccc7c00cc7cc00ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000373000000000000000000000000000
06666600006660000666660006666600044444000222220007ccc70000c7c0000cc7cc000777770007777c000cc7cc0000333000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111100001110000661660006616600046664000226220000000000000000000000000000000000000000000000000000000000000000000000000000000000
61666160066166006661666066166660444446402226222000000000000000000000000000000000000000000000000000000000000000000000000000000000
61666160666166606661666061111160466664402226222000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660444444402222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660444444402222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666660066666006666666066666660444444402222222000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666600044444000222220000000000000000000000000000000000000000000000000000000000000000000000000000000000
