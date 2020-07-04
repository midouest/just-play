local Voice = require 'voice'

local Synth = {}
Synth.__index = Synth

local NUM_VOICES = 6
local NOTE_OFFSET_V = -4

-- Convert MIDI note to v/oct
-- @param n MIDI note (0-127)
function n2v(n) return n / 12 end

-- Convert a MIDI CC value to v/oct
-- @param cc MIDI CC value (0-127)
function cc2v(cc) return (cc / 127) * 10 end


-- Initialize the Just Friends synth
function Synth.new()
  crow.ii.pullup(true)
  crow.output[1].action = "pulse(0.005, 10)"

  local synth = setmetatable({
    voice=Voice.new(NUM_VOICES, Voice.MODE_LRU),
    pitch_min=0,
    pitch_max=10,
    velocity_min=0,
    velocity_max=10,
    cc_min=0,
    cc_max=10
  }, Synth)
  synth:set_enabled(true)
  return synth
end

-- Enable or disable Just Friends synth mode
-- @param enabled true or false
function Synth:set_enabled(enabled)
  local mode = enabled and 1 or 0
  self.all_notes_off()
  crow.ii.jf.mode(mode)
end

function Synth:all_notes_off()
  crow.ii.jf.play_voice(0, 0, 0)
end

function Synth:set_pitch_range(min, max)
  self.pitch_min=min
  self.pitch_max=max
  -- TODO: rescale existing output?
end

function Synth:set_velocity_range(min, max)
  self.velocity_min=min
  self.velocity_max=max
  -- TODO: rescale existing output?
end

function Synth:set_cc_range(min, max)
  self.cc_min=min
  self.cc_max=max
  -- TODO: rescale existing output?
end

-- Play a note on Just Friends
-- @param n MIDI note
-- @param v MIDI velocity
-- @return assigned voice index
function Synth:note_on(n, v)
  local jf_n = n2v(n) + NOTE_OFFSET_V
  local jf_v = cc2v(v)

  local slot = self.voice:get()
  self.voice:push(n, slot)

  crow.ii.jf.play_voice(slot.id, jf_n, jf_v)
  crow.output[1]()
  crow.output[2].volts = util.linlin(0, 127, self.pitch_min, self.pitch_max, n)
  crow.output[3].volts = util.linlin(0, 127, self.velocity_min, self.velocity_max, v)

  return slot.id
end

-- Stop playing a note on Just Friends
-- @param n MIDI note
-- @returns assigned voice index
function Synth:note_off(n)
  local slot = self.voice:pop(n)
  if slot ~= nil then
    crow.ii.jf.play_voice(slot.id, 0, 0)
    self.voice:release(slot)
    return slot.id
  end
end

-- Apply pitchbend to Just Friends
-- @param semi Amount in semitones to transpose (+/-)
function Synth:pitchbend(semi)
  local semi_v = n2v(semi)
  crow.ii.jf.transpose(semi_v)
end

-- Output a control change value with Crow
-- @param val MIDI CC value
function Synth:control_change(val)
  crow.output[4].volts = util.linlin(0, 127, self.cc_min, self.cc_max, val)
end

return Synth
