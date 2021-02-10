local VoiceControl = include('lib/voice-control')
local Helpers = include('lib/helpers')

local Synth = {}
Synth.__index = Synth

function Synth.new(moduleCls, count)
  local modules = {}
  for i = 1, count do
    table.insert(modules, moduleCls.new(i))
  end
  return setmetatable({
    _voice = VoiceControl.new(count, moduleCls.NUM_VOICES),
    _modules = modules,
  }, Synth)
end

function Synth:cleanup()
  for _, module in pairs(self._modules) do
    module:cleanup()
  end
end

function Synth:note_on(id, note, vel)
  local note_v = Helpers.n2v(note) - 5
  local module, voice = self._voice:note_on(id)
  local vel_v = Helpers.cc2v(vel)
  self._modules[module]:voice_on(voice, note_v, vel_v)
end

function Synth:note_off(id, note)
  local note_v = Helpers.n2v(note) - 5
  local module, voice = self._voice:note_off(id)
  self._modules[module]:voice_off(voice, note_v)
end

function Synth:param(method, ...)
  for _, module in ipairs(self._modules) do
    module[method](module, ...)
  end
end

return Synth
