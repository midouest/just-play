--[[
    Class interface to 1 or more Just Friends in synth mode connected via crow
    and i2c
]] local JustFriends = {}
JustFriends.NUM_VOICES = 6 -- Maximum number of voices that can be assigned
JustFriends.__index = JustFriends

--[[
    Create a new reference to a Just Friends module connected via crow and i2c
]]
function JustFriends.new(index)
  local jf = setmetatable({_jf = crow.ii.jf[index]}, JustFriends)
  jf:_init()
  return jf
end

--[[
    Enable Just Friends synth mode
]]
function JustFriends:_init()
  self._jf.mode(1)
  self:all_voices_off()
end

-- Common interface ////////////////////////////////////////////////////////////

--[[
    Disable Just Friends synth mode
]]
function JustFriends:cleanup()
  self:all_voices_off()
  self._jf.mode(0)
end

--[[
    Stop all active voices
]]
function JustFriends:all_voices_off()
  self._jf.play_voice(0, 0, 0)
end

--[[
    Start playing a note

    @param index  voice index to play the note on
    @param note_v pitch voltage to play the note at
    @param vel_v  velocity voltage to play the note with
]]
function JustFriends:voice_on(index, note_v, vel_v)
  self._jf.play_voice(index, note_v, vel_v)
end

--[[
    Stop playing a note

    @param index  voice index to stop playing the note on
    @param note_v pitch voltage that the note was played at
]]
function JustFriends:voice_off(index, note_v)
  self._jf.play_voice(index, note_v, 0)
end

--[[
    Apply pitchbend to all voices

    @param volts pitch voltage to transpose each voice by
]]
function JustFriends:pitchbend(volts)
  self:voice_pitchbend(0, volts)
end

--[[
    Apply bitchbend to a single voice

    @param index voice index to apply pitchbend to
    @param volts pitch voltage to transpose the voice by
]]
function JustFriends:voice_pitchbend(index, volts)
  self._jf.pitch(index, volts)
end

-- Just Friends-specific interface /////////////////////////////////////////////

--[[
    Enable or disable god mode

    @param enabled true to set base frequency to 432hz, false to set base frequency
                   back to 440hz
]]
function JustFriends:god_mode(enabled)
  local mode = enabled and 1 or 0
  self._jf.god_mode(mode)
end

return JustFriends
