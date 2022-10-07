require("engine/test/bustedhelper")

local board_class = require("board")
local garbage_gate_class = require("garbage_gate")

describe('garbage_gate', function()
  local board

  before_each(function()
    board = board_class()
  end)

  describe("gate type", function()
    local garbage_gate

    before_each(function()
      garbage_gate = garbage_gate_class(1, 1, board)
    end)

    describe("type", function()
      describe("is_i", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_i())
        end)
      end)

      describe("is_h", function()
        it("should return true", function()
          assert.is_false(garbage_gate:is_h())
        end)
      end)

      describe("is_x", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_x())
        end)
      end)

      describe("is_y", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_y())
        end)
      end)

      describe("is_z", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_z())
        end)
      end)

      describe("is_s", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_s())
        end)
      end)

      describe("is_t", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_t())
        end)
      end)

      describe("is_swap", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_swap())
        end)
      end)

      describe("is_control", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_control())
        end)
      end)

      describe("is_cnot_x", function()
        it("should return false", function()
          assert.is_false(garbage_gate:is_cnot_x())
        end)
      end)

      describe("is_garbage", function()
        it("should return true", function()
          assert.is_true(garbage_gate:is_garbage())
        end)
      end)
    end)
  end)

  describe("state", function()
    local garbage_gate

    before_each(function()
      garbage_gate = garbage_gate_class(1, 1, board)
    end)

    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(garbage_gate:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(garbage_gate:is_swapping())
      end)
    end)

    describe("is_swap_finished", function()
      it("should return false", function()
        assert.is_false(garbage_gate:is_swap_finished())
      end)
    end)

    describe("is_dropping", function()
      it("should return false", function()
        assert.is_false(garbage_gate:is_dropping())
      end)
    end)

    describe("is_dropped", function()
      it("should return false", function()
        assert.is_false(garbage_gate:is_dropped())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(garbage_gate:is_match())
      end)
    end)
  end)
end)
