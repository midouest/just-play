local CrowControl = include('lib/crow-control')
local Helpers = include('lib/helpers')
local VoiceControl = include('lib/voice-control')

local Synth = {}
Synth.__index = Synth

function Synth.new(moduleCls, count)
  local modules = {}
  for i = 1, count do
    table.insert(modules, moduleCls.new(i))
  end
  return setmetatable({
    _voice = VoiceControl.new(unison and 1 or count, moduleCls.NUM_VOICES),
    _modules = modules,
    _transpose = 0,
    _pitchbend = 0,
  }, Synth)
end

function Synth:cleanup()
  for _, module in ipairs(self._modules) do
    module:cleanup()
  end
end

function Synth:note_on(id, note, vel)
  local note_v = Helpers.n2v(note) - 5
  local module, voice = self._voice:note_on(id)
  local vel_v = Helpers.cc2v(vel)
  self._modules[module]:voice_on(voice, note_v, vel_v)
  CrowControl.note_on(note_v, vel_v)
end

function Synth:note_off(id, note)
  local note_v = Helpers.n2v(note) - 5
  local module, voice = self._voice:note_off(id)
  self._modules[module]:voice_off(voice, note_v)
  CrowControl.note_off()
end

function Synth:transpose(semi)
  self._transpose = Helpers.n2v(semi)
  self:_apply_pitchbend()
end

function Synth:pitchbend(semi)
  self._pitchbend = Helpers.n2v(semi)
  self:_apply_pitchbend()
end

function Synth:_apply_pitchbend()
  for _, module in ipairs(self._modules) do
    module:pitchbend(self._transpose + self._pitchbend)
  end
end

function Synth:cc(val)
  CrowControl.cc(Helpers.cc2v(val))
end

return Synth
