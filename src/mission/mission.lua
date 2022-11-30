local flow = require("lib/flow")
local gate = require("lib/gate")

require("lib/board")

local board = create_board()
board.attack_cube_target = { 85, 30 }

require("lib/player")
local player = create_player()

require("lib/player_cursor")
local player_cursor = create_player_cursor(board)

require("mission/game")
local mission_game = game()

local gamestate = require("lib/gamestate")
local mission = derived_class(gamestate)

mission.type = ':mission'

local current_task = nil
local last_steps = 0

local reduction_rules = require("lib/reduction_rules")
local attack_bubble = require("lib/attack_bubble")
local particle = require("lib/particle")

local function shuffle(t)
  -- do a fisher-yates shuffle
  for i = #t, 1, -1 do
    local j = ceil_rnd(i)
    t[i], t[j] = t[j], t[i]
  end

  return t
end

local function cat(f, ...)
  for i, s in pairs({ ... }) do
    for k, v in pairs(s) do
      if tonum(k) then
        add(f, v)
      else
        f[k] = v
      end
    end
  end
  return f
end

--- タスク
local task_number = 1

local tasks_level1 = shuffle({
  reduction_rules.h[1],
  reduction_rules.x[1],
  reduction_rules.y[1],
  reduction_rules.z[1],
  reduction_rules.s[1],
  reduction_rules.t[1]
})
local tasks_level2 = shuffle({
  reduction_rules.x[2],
  reduction_rules.z[2]
})
local tasks_level3 = shuffle({
  reduction_rules.h[2],
  reduction_rules.h[3],
  reduction_rules.s[2],
  reduction_rules.t[2]
})
local tasks_level4 = shuffle({
  reduction_rules.control[1],
  reduction_rules.control[2]
})
local tasks_level5 = shuffle({
  reduction_rules.h[5],
  reduction_rules.x[5],
  reduction_rules.y[2],
  reduction_rules.z[5],
  reduction_rules.s[3],
  reduction_rules.t[3]
})
local tasks_level6 = {
  reduction_rules.swap[1]
}
local tasks = cat(tasks_level1, tasks_level2, tasks_level3, tasks_level4, tasks_level5, tasks_level6)

local function set_task()
  current_task = tasks[task_number]
  if current_task == nil then
    board.win = true
  else
    task_number = task_number + 1
  end
end

local function render_current_task(x, y, animate_match)
  local random_color = nil
  if animate_match then
    random_color = ceil_rnd(15)
  end

  for i, row in pairs(current_task[1]) do
    local gate1_type, gate2_type = unpack(row)
    local row_x = x
    local row_y = y + (i - 1) * 8

    if gate1_type ~= "?" then
      if gate1_type == "swap" or gate1_type == "control" or gate1_type == "cnot_x" then
        line(row_x + 3, row_y + 3, row_x + 11, row_y + 3, 10)
      end
      if animate_match then
        draw_rounded_box(row_x - 1, row_y - 1, row_x + 7, row_y + 7, random_color)
      else
        spr(gate(gate1_type).sprite_set.default, row_x, row_y)
      end
    end

    if gate2_type then
      if animate_match then
        draw_rounded_box(row_x + (match_dx * 8) - 1, row_y - 1, row_x + (match_dx + 1) * 8 - 1, row_y + 7, random_color)
      else
        spr(gate(gate2_type).sprite_set.default, row_x + 8, row_y)
      end
    end
  end
end

local all_match_circles = {}

function create_match_circle(x, y)
  add(all_match_circles, { x = x, y = y, r = 0 })
end

function update_match_circles()
  for _, each in pairs(all_match_circles) do
    local dr = 0.8
    if each.r > 35 then
      dr = 6
    end
    each.r = each.r + dr
  end
end

function render_match_circles()
  for _, each in pairs(all_match_circles) do
    circ(each.x, each.y, each.r, 7)
  end
end

state = ":play"
match_screen_x = nil
match_screen_y = nil
match_dx = nil

pattern_box_state = nil
tick_pattern_box_shake = 0

function mission_game.reduce_callback(score, x, y, player, pattern, dx)
  if current_task and current_task[5] == pattern then
    state = ":matching"
    match_dx = dx

    local attack_cube_callback = function(target_x, target_y)
      state = ":play"
      pattern_box_state = ":shake"
      sfx(10)
      particle:create_chunk(target_x, target_y,
        "10,10,9,7,random,random,-0.03,-0.03,20|10,10,9,7,random,random,-0.03,-0.03,20|9,9,9,7,random,random,-0.03,-0.03,20|9,9,2,5,random,random,-0.03,-0.03,20|9,9,6,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,9,7,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|7,7,6,5,random,random,-0.03,-0.03,20|5,5,2,5,random,random,-0.03,-0.03,20")
      set_task()
    end

    attack_bubble.slow = true
    sfx(13)
    match_screen_x = board:screen_x(x)
    match_screen_y = board:screen_y(y)
    create_match_circle(board:screen_x(x) + 3, board:screen_y(y) + 3)
    attack_bubble:create(board:screen_x(x), board:screen_y(y), attack_cube_callback, board.offset_x + board.width + 27,
      40)
  end
end

function mission:on_enter()
  task_number = 1

  player:init()

  board:init()
  board:put_random_gates()

  player_cursor:init()

  mission_game:init()
  mission_game:add_player(player, player_cursor, board)

  set_task()
end

function mission:update()
  mission_game:update()

  if player.steps > last_steps then
    -- 10 ステップごとに
    --   * ゲートをせり上げるスピードを上げる
    if player.steps > 0 and player.steps % 10 == 0 then
      if mission_game.auto_raise_frame_count > 10 then
        mission_game.auto_raise_frame_count = mission_game.auto_raise_frame_count - 1
      end
    end
    last_steps = player.steps
  end

  if mission_game:is_game_over() then
    if t() - mission_game.game_over_time > 2 then
      board.show_gameover_menu = true
      if btnp(4) then -- x でリプレイ
        flow:query_gamestate_type(":mission")
      elseif btnp(5) then -- z でタイトルへ戻る
        load('qitaev_title')
      end
    end
  end

  update_match_circles()

  if pattern_box_state == ":shake" then
    if tick_pattern_box_shake < 30 then
      tick_pattern_box_shake = tick_pattern_box_shake + 1
    else
      tick_pattern_box_shake = 0
      pattern_box_state = nil
    end
  end
end

function mission:render() -- override
  if state == ":matching" then
    ripple_speed = "slow"
  end
  render_ripple()

  if current_task then
    local pattern_box_dx, pattern_box_dy = 0, 0
    if pattern_box_state == ":shake" then
      pattern_box_dx = (ceil_rnd(3) - 2) * 2
      pattern_box_dy = (ceil_rnd(3) - 2) * 2
    end

    local pattern_box_x = board.offset_x + board.width + 10 + cos(t() / 1.5) * 2 + pattern_box_dx
    local pattern_box_y = 16 + sin(t() / 2) * 4 + 0.5 + pattern_box_dy

    draw_rounded_box(pattern_box_x, pattern_box_y, pattern_box_x + 55, pattern_box_y + 51, 7, 0)

    print_outlined("match", pattern_box_x + 5, pattern_box_y - 2, 7)
    print_outlined("the pattern!", pattern_box_x + 5, pattern_box_y + 6, 7)

    render_current_task(pattern_box_x + 15, pattern_box_y + 22)
  end

  mission_game:render()

  if state == ":matching" then
    render_current_task(match_screen_x, match_screen_y, true)
  end

  spr(70, 70, 109)
  print_outlined("swap gates", 81, 110, 7, 0)
  spr(117, 70, 119)
  print_outlined("raise gates", 81, 120, 7, 0)

  render_match_circles()
end

return mission
