require("class")

local gameapp = require("app/gameapp")
local app = derived_class(gameapp)
local solo = require("solo")

function app:_init()
  gameapp._init(self)
end

function app.instantiate_gamestates()
  return { solo() }
end

return app
