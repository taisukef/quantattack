require("engine/test/bustedhelper")

local gate_reduction_rules = require("gate_reduction_rules")
local board_class = require("board")
local h_gate = require("h_gate")
local x_gate = require("x_gate")

describe('gate_reduction_rules', function()
  describe('reduce', function()
    local board

    before_each(function()
      board = board_class()
    end)

    -- reduce -> H          I
    --           -          -
    --           H  ----->  I (next gates)
    it('should reduce HH when including next gates', function()
      board:put(1, 12, h_gate())
      board:put(1, 13, h_gate())

      local reduction = gate_reduction_rules:reduce(board, 1, board.rows, true)

      assert.are.same({ {}, { dy = 1 } }, reduction.to)
    end)

    it('should not reduce when y is the last row', function()
      local reduction = gate_reduction_rules:reduce(board, 1, board.rows)

      assert.are.same({}, reduction.to)
    end)

    --
    -- reduce -> H
    --           -
    --           X (next gates)
    it('should not reduce when y is the last and include_next_gates = true', function()
      board:put(1, board.rows, h_gate())
      board:put(1, board.row_next_gates, x_gate())

      local reduction = gate_reduction_rules:reduce(board, 1, board.rows, true)

      assert.are.same({}, reduction.to)
    end)

    --           -
    -- reduce -> I (next gates)
    it('should not reduce when y is the next gates row and include_next_gates = true', function()
      local reduction = gate_reduction_rules:reduce(board, 1, board.row_next_gates, true)

      assert.are.same({}, reduction.to)
    end)
  end)
end)
