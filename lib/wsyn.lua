--[[
    Class interface to 1 or more W/s in synth mode connected via crow and i2c
]] local WSyn = {}
WSyn.NUM_VOICES = 4 -- Maximum number of voices that can be assigned
WSyn.__index = WSyn

local function send(i, cmd)
  crow.send('ii.wsyn[' .. i .. '].' .. cmd)
end

function WSyn.init_params(i)
  params:add_separator('wsyn ' .. i)

  params:add{
    type = 'option',
    id = 'wsyn' .. i .. '_ar_mode',
    name = 'ar mode',
    options = {'off', 'on'},
    action = function(val)
      send(i, 'ar_mode(' .. (val - 1) .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_curve',
    name = 'curve',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'curve(' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_ramp',
    name = 'ramp',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'ramp(' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_fm_index',
    name = 'fm index',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'fm_index(' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_fm_env',
    name = 'fm env',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'fm_env(' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_fm_ratio_num',
    name = 'fm ratio numerator',
    controlspec = controlspec.new(1, 20, 'lin', 1, 1),
    action = function(val)
      local denom = params:get('wsyn' .. i .. '_fm_ratio_den')
      send(i, 'fm_ratio(' .. val .. ',' .. denom .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_fm_ratio_den',
    name = 'fm ratio denominator',
    controlspec = controlspec.new(1, 20, 'lin', 1, 1),
    action = function(val)
      local num = params:get('wsyn' .. i .. '_fm_ratio_num')
      send(i, 'fm_ratio(' .. num .. ',' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_lpg_time',
    name = 'lpg time',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'lpg_time(' .. val .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn' .. i .. '_lpg_symmetry',
    name = 'lpg symmetry',
    controlspec = controlspec.new(-5, 5, 'lin', 0, 0, 'v'),
    action = function(val)
      send(i, 'lpg_symmetry(' .. val .. ')')
    end,
  }
end

--[[
    Create a new reference to a W/ module connected via crow and i2c
]]
function WSyn.new(index)
  local ws = setmetatable({_index = index}, WSyn)
  ws:_init()
  return ws
end

--[[
    Send a command to the W/ module at the given index via crow i2c
]]
function WSyn:_ii(cmd)
  send(self._index, cmd)
end

function WSyn:_init()
  self:_ii("voices(4)")
  self:all_voices_off()
end

-- Common interface ////////////////////////////////////////////////////////////

function WSyn:cleanup()
  self:all_voices_off()
end

function WSyn:all_voices_off()
  self:_ii("play_voice(0, 0, 0)")
end

function WSyn:voice_on(index, note_v, vel_v)
  self:_ii("play_voice(" .. index .. "," .. note_v .. "," .. vel_v .. ")")
end

function WSyn:voice_off(index, note_v)
  self:_ii("play_voice(" .. index .. "," .. note_v .. ",0)")
end

function WSyn:pitchbend(volts)
  self:voice_pitchbend(0, volts)
end

function WSyn:voice_pitchbend(index, volts)
  self:_ii("pitch(" .. index .. "," .. volts .. ")")
end

-- WSyn-specific interface /////////////////////////////////////////////////////

--[[
    @param enabled true to enable attack-release mode, false to return to
                   attack-sustain-release mode
]]
function WSyn:ar_mode(enabled)
  local mode = enabled and 1 or 0
  self:_ii("ar_mode(" .. mode .. ")")
end

--[[
    @param volts -5=square, 0=triangle, 5=sine
]]
function WSyn:curve(volts)
  self:_ii("curve(" .. volts .. ")")
end

--[[
    @param volts -5=rampwave, 0=triangle, 5=sawtooth
]]
function WSyn:ramp(volts)
  self:_ii("ramp(" .. volts .. ")")
end

--[[
    @param volts -5=negative, 0=minimum, 5=maximum
]]
function WSyn:fm_index(volts)
  self:_ii("fm_index(" .. volts .. ")")
end

--[[
    @param volts amount of vactrol envelope applied to fm index, -5 to +5
]]
function WSyn:fm_env(volts)
  self:_ii("fm_env(" .. volts .. ")")
end

--[[
    @param numerator   FM modulator amount (0-??)
    @param denominator FM carrier amount (0-??)
]]
function WSyn:fm_ratio(numerator, denominator)
  self:_ii("fm_ratio(" .. numerator .. "," .. denominator .. ")")
end

--[[
    @param volts -5=drones, 0=vtl5c3, 5=blits
]]
function WSyn:lpg_time(volts)
  self:_ii("lpg_time(" .. volts .. ")")
end

--[[
    @param volts -5=fastest attack, 5=long swells
]]
function WSyn:lpg_symmetry(volts)
  self:_ii("lpg_symmetry(" .. volts .. ")")
end

--[[
    @param jack
    @param param
]]
function WSyn:patch(jack, param)
  self:_ii("patch(" .. jack .. "," .. param .. ")")
end

return WSyn
