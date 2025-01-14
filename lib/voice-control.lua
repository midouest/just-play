local Voice = require("voice")

local VoiceControl = {}
VoiceControl.__index = VoiceControl

function VoiceControl.new(num_modules, num_voices)
  local total_voices = num_modules * num_voices
  local voice = Voice.new(total_voices, Voice.MODE_LRU)
  return setmetatable({
    _voice = voice,
    _num_modules = num_modules,
    _num_voices = num_voices,
    _total_voices = total_voices,
  }, VoiceControl)
end

function VoiceControl:_module(id)
  return (id - 1) // self._num_voices + 1
end

function VoiceControl:is_active()
  for _ in pairs(self._voice.pairings) do
    return true
  end
  return false
end

function VoiceControl:note_on(id)
  local slot = self._voice:get()
  self._voice:push(id, slot)
  return self:_module(slot.id), (slot.id - 1) % self._num_voices + 1
end

function VoiceControl:note_off(id)
  local slot = self._voice:pop(id)
  if slot ~= nil then
    self._voice:release(slot)
    return self:_module(slot.id), (slot.id - 1) % self._num_voices + 1
  end
end

return VoiceControl
