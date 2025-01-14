-- just-play
-- play just friends with MIDI
-- v2.2.3 @midouest
CrowControl = include("lib/crow-control")
GridControl = include("lib/grid-control")
Helpers = include("lib/helpers")
JustFriends = include("lib/just-friends")
MidiControl = include("lib/midi-control")
Synth = include("lib/synth")
WSyn = include("lib/wsyn")

-- Synth instance
s = nil

function init()
  params:add_separator('just play')

  params:add{
    type = 'option',
    id = 'jp_module',
    name = 'module',
    options = {'just friends', 'wsyn'},
    action = init_synth,
  }

  params:add{
    type = 'number',
    id = 'jp_num_modules',
    name = 'num modules',
    min = 1,
    max = 2,
    default = 1,
    action = init_synth,
  }

  MidiControl.init {
    on_device = init_synth,
    on_channel = init_synth,
    on_event = midi_to_synth,
  }
  GridControl.init {on_key = grid_to_synth}
  CrowControl.init {
    on_input1 = function(v)
      local semi = Helpers.v2n(v)
      s:transpose(semi)
    end,
  }

  JustFriends.init_params()
  WSyn.init_params()

  params:default()

  redraw()
end

function cleanup()
  s:cleanup()
end

function init_synth()
  if s then
    s:cleanup()
  end

  local module = params:get('jp_module') == 1 and JustFriends or WSyn
  local num_modules = params:get('jp_num_modules')
  s = Synth.new(module, num_modules)
end

function midi_to_synth(data)
  local msg = midi.to_msg(data)

  local ch = params:get('midi_channel')
  if ch ~= 0 and msg.ch ~= ch then
    return
  end

  local cc = params:get('midi_cc')

  if msg.type == 'note_on' then
    s:note_on(msg.note, msg.note, msg.vel)
  elseif msg.type == 'note_off' then
    s:note_off(msg.note, msg.note)
  elseif msg.type == 'pitchbend' then
    local pb = params:get('midi_pitchbend')
    local semi = util.linlin(0, 16383, -pb, pb, msg.val)
    s:pitchbend(semi)
  elseif msg.type == 'cc' and msg.cc == cc then
    s:cc(msg.val)
  end
end

function grid_to_synth(x, y, z)
  local id = tostring(x) .. tostring(y)
  local note = GridControl.to_note(x, y)

  if z == 1 then
    local vel = params:get('grid_velocity')
    s:note_on(id, note, vel)
  else
    s:note_off(id, note)
  end
end

function redraw()
  screen.clear()
  screen.aa(1)

  screen.move(0, 54)
  screen.font_face(9)
  screen.font_size(24)
  screen.level(15)
  screen.text("Just play...")

  screen.update()
end
