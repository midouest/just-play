-- just-play
-- play just friends with MIDI
-- v1.4.1 @midouest
--
-- crow out 1 = trig
-- crow out 2 = pitch
-- crow out 3 = velocity
-- crow out 4 = cc

local MusicUtil = require 'musicutil'
local TabUtil = require 'tabutil'

local Synth = include('lib/synth')
local GridScale = include('lib/grid_scale')

-- state variables
local midi_device
local grid_device
local synth
local state = {}
local grid_keys = {}
local grid_scale = {}

function init()
  synth = Synth.new()

  for y=1,8 do
    local row = {}
    for x=1,16 do
      row[x] = false
    end
    grid_keys[y] = row
  end

  params:add_separator('midi')

  params:add{
    type='number',
    id='device',
    name='device',
    min=1,
    max=4,
    default=1,
    action=function(val) setup_midi(val) end
  }

  params:add{
    type='number',
    id='channel',
    name='channel',
    min=0,
    max=16,
    default=0,
    formatter=function(p) return p.value == 0 and 'any' or p.value end,
    action=function(val) synth:all_notes_off() end
  }

  params:add{
    type='number',
    id='pitchbend',
    name='pitchbend (+/-)',
    min=0,
    max=48,
    default=2,
  }

  params:add{
    type='number',
    id='cc',
    name='cc#',
    min=1,
    max=127,
    default=1,
  }

  params:add_separator('crow')

  params:add{
    type='option',
    id='pitch_range',
    name='pitch range',
    options={'0-10V', '+/-5V'},
    action=function(val) synth:set_pitch_cv_offset(val == 1 and 0 or -5) end
  }

  params:add{
    type='option',
    id='velocity_range',
    name='velocity range',
    options={'0-10V', '+/-5V'},
    action=function(val) synth:set_velocity_cv_offset(val == 1 and 0 or -5) end
  }

  params:add{
    type='option',
    id='cc_range',
    name='cc range',
    options={'0-10V', '+/-5V'},
    action=function(val) synth:set_cc_cv_offset(val == 1 and 0 or -5) end
  }

  params:add_separator('just friends')

  params:add{
    type='option',
    id='enabled',
    name='synth mode',
    options={'on', 'off'},
    action=function(val) synth:set_enabled(val == 1) end
  }

  params:add{
    type='option',
    id='god_mode',
    name='god mode',
    options={'440hz', '432hz'},
    action=function(val) synth:set_god_mode(val - 1) end
  }

  params:add{
    type='control',
    id='velocity_scale',
    name='velocity scale',
    controlspec=controlspec.new(0, 1, 'lin', 0, 0.33),
    action=function(val) synth:set_velocity_scale(val) end
  }

  params:add_separator('grid')

  params:add{
    type='number',
    id='grid_device',
    name='device',
    min=1,
    max=4,
    default=1,
    step=1,
    action=function(val) setup_grid(val) end
  }

  params:add{
    type='number',
    id='grid_velocity',
    name='fixed velocity',
    min=0,
    max=127,
    step=1,
    default=64,
  }

  params:add{
    type='number',
    id='grid_min_note',
    name='minimum note',
    min=0,
    max=127,
    step=1,
    default=48,
    formatter=function(control)
      return MusicUtil.note_num_to_name(control:get(), true)
    end
  }

  params:add{
    type='number',
    id='grid_scale',
    name='scale',
    min=1,
    max=#MusicUtil.SCALES,
    step=1,
    default=1,
    formatter=function(control)
      local val = control:get()
      return MusicUtil.SCALES[val].name
    end,
    action=function(val)
      grid_scale = GridScale.generate_grid(val, 3, 4)
      grid_redraw()
    end
  }

  params:bang()
  redraw()
end

function cleanup()
  synth:set_enabled(false)
end

function setup_midi(input)
  midi.cleanup()
  midi_device = midi.connect(input)
  midi_device.event = midi_to_synth
end

function setup_grid(input)
  grid.cleanup()
  grid_device = grid.connect(input)
  grid_device.key = grid_key
end

local keys = {}
function key(n, z)
  keys[n]=z
  if keys[2]==1 and keys[3]==1 then
    synth:all_notes_off()
    state={}
  end
end

function grid_key(x, y, z)
  local id = tostring(x)..tostring(y)

  if z == 1 then
    local vel = params:get('grid_velocity')
    local note = grid_to_note(x, y)
    synth:note_on(note, vel, id)
    grid_keys[y][x] = true
  else
    synth:note_off(id)
    grid_keys[y][x] = false
  end
  grid_redraw()
end


function grid_to_note(x, y)
  return ((8 - y) * GridScale.ROW_OFFSET) + x - 1 + params:get('grid_min_note')
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

  local x = (i - 1) * 18 + 29
  screen.move(x, 8)
  local text = note_to_text(note)
  screen.text_center(text)

  screen.line_width(16)
  screen.move(x, 62)
  local y = util.linlin(0, 127, 62, 10, vel)
  screen.line(x, y)
  screen.stroke()
end

function note_to_text(note)
  return note ~= nil and MusicUtil.note_num_to_name(note, true) or '--'
end

function grid_redraw()
  grid_device:all(0)

  for y = 1,8 do
    for x = 1,16 do
      local base = grid_scale[y][x]
      grid_device:led(x, y, grid_keys[y][x] and 15 or base)
    end
  end

  grid_device:refresh()
end
