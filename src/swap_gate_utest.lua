require("engine/test/bustedhelper")
require("engine/debug/dump")

local swap_gate_class = require("swap_gate")

describe('swap_gate', function()
  local swap_gate

  before_each(function()
    swap_gate = swap_gate_class(2)
  end)

  describe("gate type", function()
    describe("is_i", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_i())
      end)
    end)

    describe("is_h", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_h())
      end)
    end)

    describe("is_x", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_x())
      end)
    end)

    describe("is_y", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_y())
      end)
    end)

    describe("is_z", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_z())
      end)
    end)

    describe("is_s", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_s())
      end)
    end)

    describe("is_t", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_t())
      end)
    end)

    describe("is_swap", function()
      it("should return true", function()
        assert.is_true(swap_gate:is_swap())
      end)
    end)

    describe("is_control", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_control())
      end)
    end)

    describe("is_cnot_x", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_cnot_x())
      end)
    end)

    describe("is_garbage", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_garbage())
      end)
    end)
  end)

  describe("state", function()
    describe("is_idle", function()
      it("should return true", function()
        assert.is_true(swap_gate:is_idle())
      end)
    end)

    describe("is_swapping", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_swapping())
      end)
    end)

    describe("is_dropping", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_dropping())
      end)
    end)

    describe("is_match", function()
      it("should return false", function()
        assert.is_false(swap_gate:is_match())
      end)
    end)
  end)

  describe("stringify", function()
    it("should return 'swap'", function()
      assert.are.equals("swap", stringify(swap_gate))
    end)
  end)
end)
