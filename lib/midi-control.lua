local MidiControl = {}

local event_callback
local device

function MidiControl.init(options)
  event_callback = options.on_event

  params:add_separator("midi")

  params:add{
    type = "number",
    id = "midi_device",
    name = "device",
    min = 1,
    max = 4,
    default = 1,
    action = function(val)
      options.on_device(val)
      MidiControl.connect(val)
    end,
  }

  params:add{
    type = "number",
    id = "midi_channel",
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
    id = "midi_pitchbend",
    name = "pitchbend (+/-)",
    min = 0,
    max = 48,
    default = 2,
  }

  params:add{
    type = "number",
    id = "midi_cc",
    name = "cc#",
    min = 1,
    max = 127,
    default = 1,
  }
end

function MidiControl.connect(input)
  midi.cleanup()
  device = midi.connect(input)
  device.event = event_callback
end

return MidiControl
