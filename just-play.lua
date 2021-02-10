-- just-play
-- play just friends with MIDI
-- v2.0.0 @midouest
local Grid = include("lib/grid")
local Synth = include("lib/synth")
WSyn = include("lib/wsyn")
local Helpers = include("lib/helpers")

local refresh
synth = nil

function init()
  Grid.init(grid_key)
  WSyn.init_params(1)
  WSyn.init_params(2)

  params:bang()

  synth = Synth.new(WSyn, 2)

  refresh = metro.init()
  refresh.time = 1.0 / 15
  refresh.event = function()
    redraw()
  end
  refresh:start()
end

function cleanup()
  refresh:stop()
  synth:cleanup()
end

function grid_key(x, y, z)
  local id = tostring(x) .. tostring(y)
  local note = Grid.to_note(x, y)

  if z == 1 then
    local vel = params:get('grid_velocity')
    synth:note_on(id, note, vel)
  else
    synth:note_off(id, note)
  end
end

function key(n, z)
  keys[n] = z
  if keys[2] == 1 and keys[3] == 1 then
    -- todo: all notes off
  end
end

ramp = 0
curve = 0
function enc(n, d)
  if n == 2 then
  elseif n == 3 then
  end
end

function redraw()
  -- todo
end
