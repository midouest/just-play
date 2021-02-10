local MusicUtil = require("musicutil")

local Config = {}

function Config.init(options)
  Config.init_midi(options.midi or {})
  Config.init_grid(options.grid or {})
  Config.init_crow(options.crow or {})
  params:bang()
end

function Config.init_midi(options)
  params:add_separator("midi")

  params:add{
    type = "number",
    id = "device",
    name = "device",
    min = 1,
    max = 4,
    default = 1,
    action = options.on_device,
  }

  params:add{
    type = "number",
    id = "channel",
    name = "channel",
    min = 0,
    max = 16,
    default = 0,
    formatter = function(p)
      return p.value == 0 and "any" or p.value
    end,
    actions = options.on_channel,
  }

  params:add{
    type = "number",
    id = "pitchbend",
    name = "pitchbend (+/-)",
    min = 0,
    max = 48,
    default = 2,
  }

  params:add{
    type = "number",
    id = "cc",
    name = "cc#",
    min = 1,
    max = 127,
    default = 1,
  }
end

function Config.init_crow(options)
  params:add_separator("crow")

  params:add{
    type = "option",
    id = "pitch_range",
    name = "pitch range",
    options = {"0-10V", "+/-5V"},
    action = options.on_pitch_range,
  }

  params:add{
    type = "option",
    id = "velocity_range",
    name = "velocity range",
    options = {"0-10V", "+/-5V"},
    action = options.on_velocity_range,
  }

  params:add{
    type = "option",
    id = "cc_range",
    name = "cc range",
    options = {"0-10V", "+/-5V"},
    actions = options.on_cc_range,
  }
end

function Config.init_grid(options)

end

return Config
