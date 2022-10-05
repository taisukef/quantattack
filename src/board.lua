require("engine/core/class")
require("engine/debug/dump")

local garbage_gate = require("garbage_gate")
local gate_placeholder = require("gate_placeholder")
local gate_reduction_rules = require("gate_reduction_rules")
local i_gate = require("i_gate")
local quantum_gate = require("quantum_gate")

local board = new_class()

board.default_cols = 6
board.default_rows = 12

function board:_init()
  self.cols = board.default_cols
  self.rows = board.default_rows
  self.row_next_gates = board.default_rows + 1
  self._gates = {}
  self._falling_garbages = {}
  self._offset_x = 10
  self._offset_y = 10

  -- fill the board with I gates
  for x = 1, self.cols do
    self._gates[x] = {}
    for y = 1, self.row_next_gates do
      self:put(x, y, i_gate())
    end
  end
end

function board:initialize_with_random_gates()
  for x = 1, self.cols do
    for y = self.row_next_gates, 1, -1 do
      if y >= self.rows - 2 or
          (y < self.rows - 2 and y >= 6 and rnd(1) > (y - 11) * -0.1 and (not self:gate_at(x, y + 1):is_i())) then
        repeat
          self:put(x, y, quantum_gate:random_single_gate())
        until #gate_reduction_rules:reduce(self, x, y, true).to == 0
      else
        self:put(x, y, i_gate())
      end
    end
  end
end

function board:update()
  self:reduce()
  self:drop_gates()
  self:_update_falling_garbages()
  self:_update_gates()
end

function board:reduce()
  for x = 1, self.cols do
    for y = 1, self.rows - 1 do
      if not self:gate_at(x, y):is_reducible() then
        goto next
      end

      local reduction = gate_reduction_rules:reduce(self, x, y)

      for _index, r in pairs(reduction.to) do
        local dx = r.dx or 0
        local dy = r.dy or 0
        local gate = r.gate or i_gate()

        self:gate_at(x + dx, y + dy):replace_with(gate)
      end

      ::next::
    end
  end
end

function board:drop_gates()
  for x = 1, self.cols do
    for y = self.rows - 1, 1, -1 do
      local gate = self:gate_at(x, y)
      if gate:is_placeholder() or gate:is_garbage() then
        goto next
      end
      if not gate:is_droppable() then
        goto next
      end

      if self:gate_at(x, y + 1):is_i() then
        local stop_y = y
        while stop_y < self.row_next_gates and
            (self:gate_at(x, stop_y + 1):is_i() or
                self:gate_at(x, stop_y + 1):is_dropping()) do
          stop_y = stop_y + 1
        end
        gate:drop(self:screen_y(y), self:screen_y(stop_y))
        self:put(x, stop_y, gate_placeholder())
      end

      ::next::
    end
  end
end

function board:_update_falling_garbages()
  foreach(self._falling_garbages, function(each)
    if each.state == "hit gate" then
      self:put(each.x, self:y(each.stop_y), each)
    elseif each:is_idle() then
      del(self._falling_garbages, each)
    end

    each:update()
  end)
end

function board:_update_gates()
  local gates_to_swap = {}

  for x = 1, self.cols do
    for y = self.rows, 1, -1 do
      local gate = self:gate_at(x, y)
      if gate:is_placeholder() then
        goto next
      end

      gate:update()

      if gate:is_swap_finished() then
        add(gates_to_swap, { gate = gate, y = y })
      end
      if gate:is_dropped() then
        self:put(x, self:y(gate.stop_screen_y), gate)
        self:put(x, self:y(gate.start_screen_y), i_gate())
      end

      ::next::
    end
  end

  foreach(gates_to_swap, function(each)
    self:put(each.gate.swap_new_x, each.y, each.gate)
  end)
end

function board:draw()
  -- draw idle gates
  for x = 1, self.cols do
    for y = 1, self.row_next_gates do
      local gate = self:gate_at(x, y)
      if (not gate) then
        goto next
      end

      local screen_x = self:screen_x(x)
      local screen_y = self:screen_y(y) + self:dy()
      gate:render(screen_x, screen_y)

      ::next::
    end
  end

  -- draw falling garbage unitaries
  foreach(self._falling_garbages, function(each)
    each:render(self:screen_x(each.x))
  end)

  -- border left
  line(self._offset_x - 2, self._offset_y,
    self._offset_x - 2, self:screen_y(self.rows + 1),
    colors.white)
  -- border bottom
  line(self._offset_x - 1, self:screen_y(self.rows + 1),
    self._offset_x + self.cols * quantum_gate.size - 1, self:screen_y(self.rows + 1),
    colors.white)
  -- border right
  line(self._offset_x + self.cols * quantum_gate.size, self._offset_y,
    self._offset_x + self.cols * quantum_gate.size, self:screen_y(self.rows + 1),
    colors.white)
  -- mask under the border bottom
  rectfill(self._offset_x - 1, self:screen_y(self.rows + 1) + 1,
    self._offset_x + self.cols * quantum_gate.size - 1, 127,
    colors.black)
end

function board:swap(x_left, x_right, y)
  --#if assert
  assert(x_left < x_right)
  assert(y <= self.rows)
  --#endif

  local left_gate = self:gate_at(x_left, y)
  local right_gate = self:gate_at(x_right, y)

  if not (left_gate:is_swappable() and right_gate:is_swappable()) then
    return false
  end

  left_gate:swap_with_right(x_right)
  right_gate:swap_with_left(x_left)

  return true
end

function board:dy()
  if (#self._falling_garbages ~= 0) then
    return self._falling_garbages[#self._falling_garbages]:effect_dy()
  end
  return 0
end

function board:screen_x(x)
  return self._offset_x + (x - 1) * quantum_gate.size
end

function board:screen_y(y)
  return self._offset_y + (y - 1) * quantum_gate.size
end

function board:y(screen_y)
  return (screen_y - self._offset_y) / quantum_gate.size + 1
end

function board:gate_at(x, y)
  --#if assert
  assert(x >= 1)
  assert(x <= self.cols)
  assert(y >= 1)
  assert(y <= self.row_next_gates)
  --#endif

  local gate = self._gates[x][y]

  --#if assert
  assert(gate)
  --#endif

  return gate
end

function board:reducible_gate_at(x, y)
  local gate = self:gate_at(x, y)

  if gate:is_reducible() then
    return gate
  end
  return i_gate()
end

function board:put(x, y, gate)
  self._gates[x][y] = gate
end

function board:put_garbate()
  local width = flr(rnd(4)) + 3

  add(self._falling_garbages, garbage_gate(width, self))
end

function board:gate_top_y(x_start, x_end)
  for y = 1, self.rows do
    for x = x_start, x_end do
      if not self:gate_at(x, y):is_i() then
        return y
      end
    end

    for x = 1, self.cols do
      local gate = self:gate_at(x, y)
      if (gate.type ~= "g") then
        goto next
      end

      for gx = x, x + gate.width - 1, 1 do
        if (x_start <= gx and gx <= x_end) then
          return y
        end
      end

      ::next::
    end
  end
  return 1
end

function board:_tostring()
  local str = ''

  for y = 1, self.row_next_gates do
    for x = 1, self.cols do
      str = str .. stringify(self:gate_at(x, y)) .. " "
    end
    str = str .. "\n"
  end

  return str
end

return board
