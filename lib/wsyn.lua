--[[
    Class interface to 1 or more W/s in synth mode connected via crow and i2c
]] local WSyn = {}
WSyn.NUM_VOICES = 4 -- Maximum number of voices that can be assigned
WSyn.__index = WSyn

local function send(i, cmd)
  crow.send('ii.wsyn[' .. i .. '].' .. cmd)
end

local function send_both(cmd)
  send(1, cmd)
  send(2, cmd)
end

local function param_v(id, name, default)
  local name = name or id
  local default = default or 0
  params:add{
    type = 'control',
    id = 'wsyn_' .. id,
    name = name,
    controlspec = controlspec.new(-5, 5, 'lin', 0.1, default, 'v'),
    action = function(val)
      send_both(id .. '(' .. val .. ')')
    end,
  }
end

local function patch_param(i, name, default)
  local default = default or i
  params:add{
    type = 'option',
    id = 'wsyn_patch' .. i,
    name = 'patch ' .. name,
    options = {
      'ramp', 'curve', 'fm envelope', 'fm index', 'lpg time',
      'lpg symmetry', 'gate', 'v8', 'numerator', 'denominator',
    },
    default = default,
    action = function(val)
      send_both('patch(' .. i .. ',' .. val .. ')')
    end,
  }
end

function WSyn.init_params()
  params:add_separator('wsyn')

  params:add{
    type = 'option',
    id = 'wsyn_ar_mode',
    name = 'ar mode',
    options = {'off', 'on'},
    action = function(val)
      send_both('ar_mode(' .. (val - 1) .. ')')
    end,
  }

  param_v('curve')
  param_v('ramp')
  param_v('fm_index', 'fm index')
  param_v('fm_env', 'fm envelope')

  params:add{
    type = 'control',
    id = 'wsyn_fm_ratio_num',
    name = 'fm ratio numerator',
    controlspec = controlspec.new(1, 20, 'lin', 1, 1),
    action = function(val)
      local denom = params:get('wsyn_fm_ratio_den')
      send_both('fm_ratio(' .. val .. ',' .. denom .. ')')
    end,
  }

  params:add{
    type = 'control',
    id = 'wsyn_fm_ratio_den',
    name = 'fm ratio denominator',
    controlspec = controlspec.new(1, 20, 'lin', 1, 1),
    action = function(val)
      local num = params:get('wsyn_fm_ratio_num')
      send_both('fm_ratio(' .. num .. ',' .. val .. ')')
    end,
  }

  param_v('lpg_time', 'lpg time')
  param_v('lpg_symmetry', 'lpg symmetry', -5)

  patch_param(1, 'this', 7)
  patch_param(2, 'that', 8)
end

--[[
    Create a new reference to a W/ module connected via crow and i2c
]]
function WSyn.new(index)
  local ws = setmetatable({_index = index, _pitches = {}}, WSyn)
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

function WSyn:cleanup()
  self:all_voices_off()
end

function WSyn:all_voices_off()
  self:_ii("play_voice(0, 0, 0)")
  self._pitches = {}
end

function WSyn:voice_on(index, note_v, vel_v)
  self:_ii("play_voice(" .. index .. "," .. note_v .. "," .. vel_v .. ")")
  self._pitches[index] = note_v
end

function WSyn:voice_off(index, note_v)
  self:_ii("play_voice(" .. index .. "," .. note_v .. ",0)")
  self._pitches[index] = nil
end

function WSyn:pitchbend(volts)
  for index, base in pairs(self._pitches) do
    self:_ii("pitch(" .. index .. "," .. base + volts .. ")")
  end
end

return WSyn
