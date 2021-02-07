-- just-play
-- play just friends with MIDI
-- v2.0.0 @midouest
local Config = include("lib/config")

local refresh

function init()
  Config.init {
    midi = {
      on_device = function(input)
        -- todo
      end,
      on_channel = function(channel)
        -- todo
      end,
    },
    grid = {
      on_device = function(input)
        -- todo
      end,
      on_min_note = function(note)
        -- todo
      end,
      on_scale = function(scale)
        -- todo
      end,
    },
    crow = {
      on_pitch_range = function(value)
        -- todo
      end,
      on_velocity_range = function(value)
        -- todo
      end,
      on_cc_range = function(value)
        -- todo
      end,
    },
  }

  refresh = metro.init()
  refresh.time = 1.0 / 15
  refresh.event = function()
    redraw()
  end
  refresh:start()
end

function cleanup()
  refresh:stop()
end

function key(n, z)
  keys[n] = z
  if keys[2] == 1 and keys[3] == 1 then
    -- todo: all notes off
  end
end

function redraw()
  -- todo
end
