-- just-play
-- play just friends with MIDI
-- v1.1.0 @midouest
--
-- crow out 1 = trig
-- crow out 2 = pitch
-- crow out 3 = velocity
-- crow out 4 = cc

local Synth = include('lib/synth')

local m
local synth
local state = {}

function init()
  synth = Synth.new()

  params:add_separator('midi')

  params:add{
    type='number',
    id='device',
    name='device',
    min=1,
    max=4,
    default=1,
    action=function(val)
      setup_midi(val)
      params:write()
    end
  }

  params:add{
    type='number',
    id='channel',
    name='channel',
    min=0,
    max=16,
    default=0,
    formatter=function(p) return p.value == 0 and 'any' or p.value end,
    action=function(val)
      synth:all_notes_off()
      params:write()
    end
  }

  params:add{
    type='number',
    id='pitchbend',
    name='pitchbend (+/-)',
    min=0,
    max=48,
    default=2,
    action=function(val) params:write() end
  }

  params:add{
    type='number',
    id='cc_num',
    name='cc#',
    min=1,
    max=127,
    default=1,
    action=function(val) params:write() end
  }

  params:add_separator('crow')

  params:add{
    type='option',
    id='pitch_range',
    name='pitch range',
    options={'0-10V', '+/-5V'},
    action=function(val)
      synth:set_pitch_cv_offset(val == 1 and 0 or -5)
      params:write()
    end
  }

  params:add{
    type='option',
    id='velocity_range',
    name='velocity range',
    options={'0-10V', '+/-5V'},
    action=function(val)
      synth:set_velocity_cv_offset(val == 1 and 0 or -5)
      params:write()
    end
  }

  params:add{
    type='option',
    id='cc_range',
    name='cc range',
    options={'0-10V', '+/-5V'},
    action=function(val)
      synth:set_cc_cv_offset(val == 1 and 0 or -5)
      params:write()
    end
  }

  params:add_separator('just friends')

  params:add{
    type='option',
    id='enabled',
    name='synth mode',
    options={'on', 'off'},
    action=function(val)
      synth:set_enabled(val == 1)
      params:write()
    end
  }

  params:read()
  params:bang()
  redraw()
end

function setup_midi(input)
  midi.cleanup()
  m = midi.connect(input)
  m.event = midi_to_synth
end

local keys = {}
function key(n, z)
  keys[n]=z
  if keys[2]==1 and keys[3]==1 then
    synth:all_notes_off()
    state={}
  end
end

function midi_to_synth(data)
  local msg = midi.to_msg(data)

  local ch = params:get('channel')
  if ch ~= 0 and msg.ch ~= ch then
    return
  end

  local cc=params:get('cc')

  if msg.type == 'note_on' then
    local index = synth:note_on(msg.note, msg.vel)
    state[index] = {note=msg.note, velocity=msg.vel}
  elseif msg.type == 'note_off' then
    local index = synth:note_off(msg.note)
    if index ~= nil then
      state[index].note = nil
    end
  elseif msg.type == 'pitchbend' then
    local pb=params:get('pitchbend')
    local semi = util.linlin(0, 16383, -pb, pb, msg.val)
    synth:pitchbend(semi)
    state.pitchbend=msg.val
  elseif msg.type == 'cc' and msg.cc == cc then
    synth:control_change(msg.val)
    state.cc=msg.val
  end

  redraw()
end

function redraw()
  screen.clear()

  screen.line_width(8)

  screen.level(15)
  screen.move(0, 8)
  screen.text('PB')
  screen.stroke()

  screen.move(5, 36)
  local pb_y = util.linlin(0, 16383, 62, 10, state.pitchbend or 16383 / 2)
  screen.line(5, pb_y)
  screen.stroke()

  screen.move(11, 8)
  screen.text('CC')
  screen.stroke()

  screen.move(15, 62)
  local cc_y = util.linlin(0, 127, 62, 10, state.cc or 0)
  screen.line(15, cc_y)
  screen.stroke()

  for i=1,6 do
    redraw_voice(i)
  end
  screen.update()
end

function redraw_voice(i)
  local s = state[i]
  local note = s and s.note or nil
  local vel = s and s.velocity or 0

  if note == nil then
    screen.level(1)
  else
    screen.level(15)
  end

  local x = (i - 1) * 18 + 21
  screen.move(x, 8)
  local text = note_to_text(note)
  screen.text(text)

  screen.line_width(16)
  screen.move(x + 8, 62)
  local y = util.linlin(0, 127, 62, 10, vel)
  screen.line(x + 8, y)
  screen.stroke()
end

local pitch_names = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'}
function note_to_text(note)
  if note == nil then
    return '--'
  end

  local pitch = note % 12 + 1
  local name = pitch_names[pitch]
  local octave = math.floor(note / 12) - 1
  return tostring(name)..tostring(octave)
end
