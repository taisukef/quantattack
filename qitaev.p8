pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include colors.lua
#include dropping_particle.lua
#include game.lua
#include player_cursor.lua
#include quantum_gate.lua
#include board.lua
#include puff_particle.lua
#include gate_reduction_rules.lua

function _init()
  game:init()
end

function _update60()
  game:update()
end

function _draw()
  game:draw()
end

__gfx__
066666000066600006666600066666000666660006666600000000000000000007ccc70000c7c00007ccc700077777000c77770007777700000000000c101c00
616661600661660061666160611111606611116061111160000000000b101b00c7ccc7c00cc7cc00cc7c7cc0cccc7cc0c7ccccc0ccc7ccc00000000001c1c100
6166616066616660661616606666166061666660666166600044400001b1b100c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc000001c1000
61111160611111606661666066616660661116606661666000444000001b1000c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000ccc00001c1c100
6166616066616660666166606616666066666160666166600044400001b1b100c7ccc7c0ccc7ccc0ccc7ccc0c77777c0c7777cc0ccc7ccc0001110000c101c00
616661600661660066616660611111606111166066616660000000000b101b00ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc00000000000000000
06666600006660000666660006666600066666000666660000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666600066666000666660000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
666666600666660066666660666666606666666066666660000000000b101b00c7ccc7c00cc7cc00c7ccc7c0c77777c0cc7777c0c77777c0000000000c101c00
6666666066666660666666606666666066666660666666600000000001b1b100c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000ccc00001c1c100
61666160666166606166616061111160661111606111116000555000001b1000c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc000001c1000
6166616066616660661616606666166061666660666166600044400001b1b100c7ccc7c0ccc7ccc0ccc7ccc0cc7cccc0ccccc7c0ccc7ccc000ccc00001c1c100
611111600111110066616660661166606611116066616660004440000b101b00c7ccc7c00cc7cc00ccc7ccc0c77777c0c7777cc0ccc7ccc0000000000c101c00
01161100006160000661660001111100011111000661660000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01666100006160000166610001111100061111000111110000000000000000000ccccc0000ccc0000ccccc000ccccc000ccccc000ccccc000000000000000000
616661600661660066161660666616606166666066616660004440000b101b00ccccccc00ccccc00ccccccc0ccccccc0ccccccc0ccccccc00000000000000000
6111116061111160666166606661666066111660666166600044400001b1b100c7ccc7c0ccc7ccc0c7ccc7c0c77777c0cc7777c0c77777c0001110000c101c00
61666160666166606661666066166660666661606661666000444000001b1000c7ccc7c0ccc7ccc0cc7c7cc0cccc7cc0c7ccccc0ccc7ccc000ccc00001c1c100
6166616066616660666166606111116061111660666166600000000001b1b100c77777c0c77777c0ccc7ccc0ccc7ccc0cc777cc0ccc7ccc000ccc000001c1000
666666600666660066666660666666606666666066666660000000000b101b00c7ccc7c00cc7cc00ccc7ccc0cc7cccc0ccccc7c0ccc7ccc00000000001c1c100
066666000066600006666600066666000666660006666600000000000000000007ccc70000c7c0000cc7cc000777770007777c000cc7cc00000000000c101c00
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111100001110000661660006616600061116000661660000444000000000000000000000000000000000000000000000000000000000000000000000000000
616661600661660066616660661666606666616066616660004440000b101b000000000000000000000000000000000000000000000000000000000000000000
6166616066616660666166606111116061111660666166600044400001b1b1000000000000000000000000000000000000000000000000000000000000000000
66666660666666606666666066666660666666606666666000000000001b10000000000000000000000000000000000000000000000000000000000000000000
6666666066666660666666606666666066666660666666600000000001b1b1000000000000000000000000000000000000000000000000000000000000000000
666666600666660066666660666666606666666066666660000000000b101b000000000000000000000000000000000000000000000000000000000000000000
06666600006660000666660006666600066666000666660000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050003333303333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505003777303777773000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050003733303337333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505003730000037300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
50505050003330000033300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05050505000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100002202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010200001003011030110300672007720067200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100002b0102d01031010336102e0102f0103160000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000178201d820248202b8202f83030830328303483035830308302b8301c8301c8301c8301c8301c8301c8301f830238302483029830248301f8201f8201e8201f8202282024830298302e8303382037820
0004000004b1004b1005b1004b1004b1004b1005b1004b1004b1006b1004b1004b1005b1004b1005b1005b1005b1005b1005b1003b1006b1006b1004b1007b1007b1007b1005b1007b1007b1004b1007b1003b10
