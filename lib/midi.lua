local Midi = {}

local event_callback

function Midi.init(callback)
  event_callback = callback
end

function Midi.connect(device)
  midi.cleanup()
  Midi.device = midi.connect(device)
  Midi.device.event = event_callback
end

return Midi
