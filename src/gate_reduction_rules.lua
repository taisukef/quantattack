local i_gate = require("i_gate")
local x_gate = require("x_gate")
local y_gate = require("y_gate")
local z_gate = require("z_gate")
local s_gate = require("s_gate")
local control_gate = require("control_gate")
local cnot_x_gate = require("cnot_x_gate")
local swap_gate = require("swap_gate")

-- TODO: singleton にする
local gate_reduction_rules = {
  reduce = function(self, board, x, y, include_next_gates)
    local default = { to = {} }

    include_next_gates = include_next_gates or false
    local y1 = y + 1
    local y2 = y + 2
    local y3 = y + 3

    if include_next_gates then
      if y1 > board.row_next_gates then
        return default
      end
    else
      if y1 > board.rows then
        return default
      end
    end

    local gate = board:reducible_gate_at(x, y)
    local other_gate = i_gate()
    local gate_y1 = board:reducible_gate_at(x, y1)
    local gate_y1_other_gate = i_gate()

    if gate.other_x then
      other_gate = board:reducible_gate_at(gate.other_x, y)
    end
    if gate_y1.other_x then
      gate_y1_other_gate = board:reducible_gate_at(gate_y1.other_x, y1)
    end

    if gate_y1:is_i() then
      return default
    end

    --  H          I
    --  H  ----->  I
    if gate:is_h() and
        gate_y1:is_h() then
      return {
        to = { {},
          { dy = 1 } },
      }
    end

    if gate:is_x() then
      if gate_y1:is_x() then
        --  X          I
        --  X  ----->  I
        return {
          to = { {},
            { dy = 1 } },
        }
      end
      if gate_y1:is_z() then
        --  X          I
        --  Z  ----->  Y
        return {
          score = 200,
          to = { {},
            { dy = 1, gate = y_gate() } },
        }
      end
    end

    --  Y          I
    --  Y  ----->  I
    if gate:is_y() and
        gate_y1:is_y() then
      return {
        to = { {},
          { dy = 1 } },
      }
    end

    if gate:is_z() then
      if gate_y1:is_z() then
        --  Z          I
        --  Z  ----->  I
        return {
          to = { {},
            { dy = 1 } },
        }
      elseif gate_y1:is_x() then
        --  Z          I
        --  X  ----->  Y
        return {
          score = 200,
          to = { {},
            { dy = 1, gate = y_gate() } },
        }
      end
    end

    --  S          I
    --  S  ----->  Z
    if gate:is_s() and
        gate_y1:is_s() then
      return {
        to = { {},
          { dy = 1, gate = z_gate() } },
      }
    end

    --  T          I
    --  T  ----->  S
    if gate:is_t() and
        gate_y1:is_t() then
      return {
        to = { {},
          { dy = 1, gate = s_gate() } },
      }
    end

    --  SWAP-SWAP          I I
    --  SWAP-SWAP  ----->  I I
    if gate.other_x == gate_y1.other_x and
        gate:is_swap() and other_gate:is_swap() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() then
      local dx = gate.other_x - x
      return {
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 } },
      }
    end

    --  C-X          I I
    --  C-X  ----->  I I
    if gate.other_x == gate_y1.other_x and
        gate:is_control() and other_gate:is_cnot_x() and
        gate_y1:is_control() and gate_y1_other_gate:is_cnot_x() then
      local dx = gate.other_x - x
      return {
        score = 200,
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 } },
      }
    end

    if include_next_gates then
      if y2 > board.row_next_gates then
        return default
      end
    else
      if y2 > board.rows then
        return default
      end
    end

    local gate_y2 = board:reducible_gate_at(x, y2)
    local gate_y2_other_gate = i_gate()
    if gate_y2.other_x then
      gate_y2_other_gate = board:reducible_gate_at(gate_y2.other_x, y2)
    end

    --  H          I
    --  X          I
    --  H  ----->  Z
    if gate:is_h() and
        gate_y1:is_x() and
        gate_y2:is_h() then
      return {
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = z_gate() } },
      }
    end

    --  H          I
    --  Z          I
    --  H  ----->  X
    if gate:is_h() and
        gate_y1:is_z() and
        gate_y2:is_h() then
      return {
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = x_gate() } },
      }
    end

    --  S          I
    --  Z          I
    --  S  ----->  Z
    if gate:is_s() and
        gate_y1:is_z() and
        gate_y2:is_s() then
      return {
        score = 400,
        to = { {},
          { dy = 1 },
          { dy = 2, gate = z_gate() } },
      }
    end

    --  C-X             I I
    --  X-C             I I
    --  C-X  ----->  SWAP-SWAP
    if gate:is_control() and other_gate:is_cnot_x() and
        gate_y1:is_cnot_x() and gate_y1_other_gate:is_control() and
        gate_y2:is_control() and gate_y2_other_gate:is_cnot_x() and
        gate.other_x == gate_y1.other_x and
        gate.other_x == gate_y2.other_x then
      local dx = gate.other_x - x
      return {
        score = 800,
        to = { {}, { dx = dx },
          { dy = 1 }, { dx = dx, dy = 1 },
          { dy = 2, gate = swap_gate(x + dx) }, { dx = dx, dy = 2, gate = swap_gate(x) } },
      }
    end

    -- H H          I I
    -- C-X  ----->  X-C
    -- H H          I I
    if gate:is_h() and gate_y1:is_control() and board:reducible_gate_at(gate_y1.other_x, y):is_h() and
        gate_y1_other_gate:is_cnot_x() and
        gate_y2:is_h() and board:reducible_gate_at(gate_y1.other_x, y2):is_h() then
      local dx = gate_y1.other_x - x
      return {
        score = 800,
        to = { {}, { dx = dx },
          { dy = 1, gate = cnot_x_gate(x + dx) }, { dx = dx, dy = 1, gate = control_gate(x) },
          { dy = 2 }, { dx = dx, dy = 2 } },
      }
    end

    -- X X          I I
    -- C-X  ----->  C-X
    -- X            I
    if gate:is_x() and gate_y1:is_control() and board:reducible_gate_at(gate_y1.other_x, y):is_x() and
        gate_y1_other_gate:is_cnot_x() and
        gate_y2:is_x() then
      return {
        score = 800,
        to = { {}, { dx = gate_y1.other_x - x }, { dy = 2 } },
      }
    end

    -- Z Z          I I
    -- C-X  ----->  C-X
    --   Z            I
    if gate:is_z() and gate_y1:is_control() and board:reducible_gate_at(gate_y1.other_x, y):is_z() and
        gate_y1_other_gate:is_cnot_x() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_z() then
      local dx = gate_y1.other_x - x
      return {
        score = 800,
        to = { {}, { dx = dx }, { dx = dx, dy = 2 } },
      }
    end

    -- X            I
    -- X-C  ----->  X-C
    -- X            I
    if gate:is_x() and
        gate_y1:is_cnot_x() and gate_y1_other_gate:is_control() and
        gate_y2:is_x() then
      return {
        score = 800,
        to = { {}, { dy = 2 } },
      }
    end

    -- Z            I
    -- C-X  ----->  C-X
    -- Z            I
    if gate:is_z() and
        gate_y1:is_control() and gate_y1_other_gate:is_cnot_x() and
        gate_y2:is_z() then
      return {
        score = 800,
        to = { {}, { dy = 2 } },
      }
    end

    -- Z            I
    -- H X          H I
    -- X-C  ----->  X-C
    -- H X          H I
    local x2 = gate_y2.other_x
    if y <= 9 and
        gate:is_z() and
        gate_y1:is_h() and board:reducible_gate_at(x2, y1):is_x() and
        gate_y2:is_cnot_x() and board:reducible_gate_at(x2, y2):is_control() and
        board:reducible_gate_at(x, y3):is_h() and board:reducible_gate_at(x2, y3):is_x() then
      local dx = gate_y2.other_x - x
      return {
        score = 800,
        to = { {},
          { dx = dx, dy = 1 },
          { dx = dx, dy = 3 } }
      }
    end

    -- H                  I
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         H                  I
    if gate:is_h() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_h() then
      return {
        score = 600,
        to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    -- X                  I
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         X                  I
    if gate:is_x() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_x() then
      return {
        score = 600,
        to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    -- Y                  I
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         Y                  I
    if gate:is_y() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_y() then
      return {
        score = 600,
        to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    -- Z                  I
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         Z                  I
    if gate:is_z() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_z() then
      return {
        score = 600,
        to = { {}, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    -- S                  Z
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         S                  I
    if gate:is_s() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_s() then
      return {
        score = 600,
        to = { { gate = z_gate() }, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    -- T                  S
    -- SWAP-SWAP  ----->  SWAP-SWAP
    --         T                  I
    if gate:is_t() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        board:reducible_gate_at(gate_y1.other_x, y2):is_t() then
      return {
        score = 600,
        to = { { gate = s_gate() }, { dx = gate_y1.other_x - x, dy = 2 } }
      }
    end

    --  C-------X          I       I
    --  SWAP-SWAP          SWAP-SWAP
    --  X-------C  ----->  I       I
    if gate:is_control() and other_gate:is_cnot_x() and
        gate_y1:is_swap() and gate_y1_other_gate:is_swap() and
        gate_y2:is_cnot_x() and gate_y2_other_gate:is_control() and
        gate.other_x == gate_y1.other_x and gate.other_x == gate_y2.other_x then
      local dx = gate.other_x - x
      return {
        score = 800,
        to = { {}, { dx = dx },
          { dy = 2 }, { dx = dx, dy = 2 } }
      }
    end

    return default
  end,
}

return gate_reduction_rules
