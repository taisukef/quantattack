
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

    if (board:reducible_gate_at(x, y):is_h() and
        board:reducible_gate_at(x, y + 1):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (board:reducible_gate_at(x, y):is_x() and
        board:reducible_gate_at(x, y + 1):is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (board:reducible_gate_at(x, y):is_y() and
        board:reducible_gate_at(x, y + 1):is_y()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (board:reducible_gate_at(x, y):is_z() and
        board:reducible_gate_at(x, y + 1):is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
      }
    end

    if (board:reducible_gate_at(x, y):is_z() and
        board:reducible_gate_at(x, y + 1):is_x()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() },
      }
    end

    if (board:reducible_gate_at(x, y):is_x() and
        board:reducible_gate_at(x, y + 1):is_z()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:y() },
      }
    end

    if (board:reducible_gate_at(x, y):is_s() and
        board:reducible_gate_at(x, y + 1):is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:z() },
      }
    end

    if (board:reducible_gate_at(x, y):is_t() and
        board:reducible_gate_at(x, y + 1):is_t()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:s() },
      }
    end

    if (board:reducible_gate_at(x, y):is_swap() and
        board:reducible_gate_at(x, y + 1):is_swap() and
        board:reducible_gate_at(board:reducible_gate_at(x, y).other_x, y + 1):is_swap()) then 
      local dx = board:reducible_gate_at(x, y).other_x - x
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
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

    if (board:reducible_gate_at(x, y):is_h() and
        board:reducible_gate_at(x, y + 1):is_x() and
        board:reducible_gate_at(x, y + 2):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() },
      }      
    end 

    if (board:reducible_gate_at(x, y):is_h() and
        board:reducible_gate_at(x, y + 1):is_z() and
        board:reducible_gate_at(x, y + 2):is_h()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:x() },
      }
    end 

    if (board:reducible_gate_at(x, y):is_s() and
        board:reducible_gate_at(x, y + 1):is_z() and
        board:reducible_gate_at(x, y + 2):is_s()) then
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:z() },
      }      
    end

    -- c -- x   x -- c
    -- x -- c   c -- x  --> 
    -- c -- x,  x -- c       swap -- swap
    if (board:reducible_gate_at(x, y):is_c() and
       (board:reducible_gate_at(x, y + 1):is_cnot_x()) and
        board:reducible_gate_at(x, y + 2):is_c() and
        board:reducible_gate_at(board:reducible_gate_at(x, y).cnot_x_x, y + 1):is_c() and
        board:reducible_gate_at(board:reducible_gate_at(x, y).cnot_x_x, y + 2):is_cnot_x()) then
      local dx = board:reducible_gate_at(x, y).cnot_x_x - x
      return {
        { ["dx"] = 0, ["dy"] = 0, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 0, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 1, ["gate"] = quantum_gate:i() }, { ["dx"] = dx, ["dy"] = 1, ["gate"] = quantum_gate:i() },
        { ["dx"] = 0, ["dy"] = 2, ["gate"] = quantum_gate:swap(x + dx) }, { ["dx"] = dx, ["dy"] = 2, ["gate"] = quantum_gate:swap(x) },
      }  
    end

    -- todo:
    -- h    h
    -- c -- x  -->
    -- h    h       x -- c

    return {}
  end,
}