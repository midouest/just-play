--[[
    Class interface to 1 or more W/s in synth mode connected via crow and i2c
]] local WSyn = {}
WSyn.NUM_VOICES = 4 -- Maximum number of voices that can be assigned
WSyn.__index = WSyn

--[[
    Create a new reference to a W/ module connected via crow and i2c
]]
function WSyn.new(index)
  local prefix = "ii.wsyn[" .. index .. "]."
  local ws = setmetatable({_prefix = prefix}, WSyn)
  ws:_init()
  return ws
end

--[[
    Send a command to the W/ module at the given index via crow i2c
]]
function WSyn:_ii(cmd)
  crow.send(self._prefix .. cmd)
end

function WSyn:_init()
  self._ii("voices(4)")
  self:all_notes_off()
end

-- Common interface ////////////////////////////////////////////////////////////

function WSyn:cleanup()
  self:all_notes_off()
end

function WSyn:all_voices_off()
  self._ii("play_voice(0, 0, 0)")
end

function WSyn:voice_on(index, note_v, vel_v)
  self._ii("play_voice(" .. index .. "," .. note_v .. "," .. vel_v .. ")")
end

function WSyn:voice_off(index, note_v)
  self._ii("play_voice(" .. index .. "," .. note_v .. ",0)")
end

function WSyn:pitchbend(volts)
  self:voice_pitchbend(0, volts)
end

function WSyn:voice_pitchbend(index, volts)
  self._ii("pitch(" .. index .. "," .. volts .. ")")
end

-- WSyn-specific interface /////////////////////////////////////////////////////

--[[
    @param enabled true to enable attack-release mode, false to return to
                   attack-sustain-release mode
]]
function WSyn:ar_mode(enabled)
  local mode = enabled and 1 or 0
  self._ii("ar_mode(" .. mode .. ")")
end

--[[
    @param volts -5=square, 0=triangle, 5=sine
]]
function WSyn:curve(volts)
  self._ii("curve(" .. volts .. ")")
end

--[[
    @param volts -5=rampwave, 0=triangle, 5=sawtooth
]]
function WSyn:ramp(volts)
  self._ii("ramp(" .. volts .. ")")
end

--[[
    @param volts -5=negative, 0=minimum, 5=maximum
]]
function WSyn:fm_index(volts)
  self._ii("fm_index(" .. volts .. ")")
end

--[[
    @param volts amount of vactrol envelope applied to fm index, -5 to +5
]]
function WSyn:fm_env(volts)
  self._ii("fm_env(" .. volts .. ")")
end

--[[
    @param numerator   FM modulator amount (0-??)
    @param denominator FM carrier amount (0-??)
]]
function WSyn:fm_ratio(numerator, denominator)
  self._ii("fm_ratio(" .. numerator .. "," .. denominator .. ")")
end

--[[
    @param volts -5=drones, 0=vtl5c3, 5=blits
]]
function WSyn:lpg_time(volts)
  self._ii("lpg_time(" .. volts .. ")")
end

--[[
    @param volts -5=fastest attack, 5=long swells
]]
function WSyn:lpg_symmetry(volts)
  self._ii("lpg_symmetry(" .. volts .. ")")
end

--[[
    @param jack
    @param param
]]
function WSyn:patch(jack, param)
  self._ii("patch(" .. jack .. "," .. param .. ")")
end

return WSyn
