-- just-play
-- play just friends with MIDI
-- v1.0.0 @midouest
--
-- crow out 1 = trig
-- crow out 2 = pitch
-- crow out 3 = velocity
-- crow out 4 = cc1

local Synth = include('lib/synth')
local m = midi.connect()

local synth
local midi_cc
local pitchbend_range
local state = {}

function init()
  synth = Synth.new()

  params:add{
    type='option',
    id='enabled',
    name='enabled',
    options={'on', 'off'}
  }
  params:set_action('enabled', function(val) synth:set_enabled(val == 1) end)

  params:add{
    type='option',
    id='pitch_range',
    name='pitch range',
    options={'0-10V', '+/-5V'}
  }
  params:set_action('pitch_range', function(val)
    if val == 1 then
      synth:set_pitch_range(0, 10)
    else
      synth:set_pitch_range(-5, 5)
    end
  end)

  params:add{
    type='option',
    id='velocity_range',
    name='velocity range',
    options={'0-10V', '+/-5V'}
  }
  params:set_action('velocity_range', function(val)
    if val == 1 then
      synth:set_velocity_range(0, 10)
    else
      synth:set_velocity_range(-5, 5)
    end
  end)

  params:add{
    type='number',
    id='pitchbend_range',
    name='pitchbend range (+/-)',
    min=0,
    max=48,
    default=2
  }
  params:set_action('pitchbend_range', function(val) pitchbend_range = val end)

  params:add{
    type='number',
    id='midi_cc',
    name='midi cc',
    min=0,
    max=127,
    default=1
  }
  params:set_action('midi_cc', function(val) midi_cc = val end)

  params:add{
    type='option',
    id='midi_cc_range',
    name='midi cc range',
    options={'0-10V', '+/-5V'}
  }
  params:set_action('midi_cc_range', function(val)
    if val == 1 then
      synth:set_cc_range(0, 10)
    else
      synth:set_cc_range(-5, 5)
    end
  end)

  params:bang()
  redraw()
end

function update_enabled(enabled)
  synth:set_enabled(enabled == 'on')
end

m.event = function(data)
  local msg = midi.to_msg(data)
  if msg.type == 'note_on' then
    local index = synth:note_on(msg.note, msg.vel)
    state[index] = {note=msg.note, velocity=msg.vel}
  elseif msg.type == 'note_off' then
    local index = synth:note_off(msg.note)
    if index ~= nil then
      state[index].note = nil
    end
  elseif msg.type == 'pitchbend' then
    local semi = util.linlin(0, 16383, -pitchbend_range, pitchbend_range, msg.val)
    synth:pitchbend(semi)
    state.pitchbend=msg.val
  elseif msg.type == 'cc' and msg.cc == midi_cc then
    synth:control_change(msg.val)
    state.cc=msg.val
  end
  redraw()
end

function redraw()
  screen.clear()

  screen.line_width(2)

  screen.level(1)
  screen.move(0, 8)
  screen.text('PB')
  screen.stroke()

  screen.move(1, 36)
  local pb_y = util.linlin(0, 16383, 62, 10, state.pitchbend or 16383 / 2)
  screen.line(1, pb_y)
  screen.stroke()

  screen.move(16, 8)
  screen.text('CC')
  screen.stroke()

  screen.move(17, 62)
  local cc_y = util.linlin(0, 127, 62, 10, state.cc or 0)
  screen.line(17, cc_y)
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

  local x = (i - 1) * 16 + 32
  screen.move(x, 8)
  local text = note_to_text(note)
  screen.text(text)

  screen.move(x + 1, 62)
  local y = util.linlin(0, 127, 62, 10, vel)
  screen.line(x + 1, y)
  screen.stroke()
end

notes = {'C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'}
function note_to_text(note)
  if note == nil then
    return '-'
  end

  local pitch = note % 12 + 1
  local name = notes[pitch]
  local octave = math.floor(note / 12)
  return tostring(name)..tostring(octave)
end
