--[[
    Class interface to 1 or more Just Friends in synth mode connected via crow
    and i2c
]] local JustFriends = {}
JustFriends.NUM_VOICES = 6 -- Maximum number of voices that can be assigned
JustFriends.__index = JustFriends

function JustFriends.init_params()
  params:add_separator('just friends')

  params:add{
    type = 'option',
    id = 'jf_god_mode',
    name = 'god mode',
    options = {'440hz', '432hz'},
    action = function(val)
      crow.ii.jf.god_mode(val - 1)
    end,
  }

  params:add{
    type = 'option',
    id = 'jf_run_mode',
    name = 'run mode',
    options = {'off', 'on'},
    action = function(val)
      crow.ii.jf.run_mode(val - 1)
    end,
  }

  params:add{
    type = 'control',
    id = 'jf_run',
    name = "run",
    controlspec = controlspec.new(-5, 5, 'lin', 0.1, 0, 'v'),
    action = function(val)
      crow.ii.jf.run(val)
    end,
  }
end

--[[
    Create a new reference to a Just Friends module connected via crow and i2c
]]
function JustFriends.new()
  local jf = setmetatable({_jf = crow.ii.jf}, JustFriends)
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
  self._jf.transpose(volts)
end

return JustFriends
