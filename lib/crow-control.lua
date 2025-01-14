local CrowControl = {}

local note_offset_v = 0
local velocity_offset_v = 0
local cc_offset_v = 0

function CrowControl.init(options)
  crow.input[1].stream = function(v)
    options.on_input1(v)
  end

  crow.output[1].action = "pulse(0.005, 10)"

  CrowControl.init_params()
end

function CrowControl.init_params()
  params:add_separator("crow")

  params:add{
    type = "option",
    id = "crow_pitch_range",
    name = "pitch range",
    options = {"0-10V", "+/-5V"},
    action = function(val)
      note_offset_v = val and 0 or -5
    end,
  }

  params:add{
    type = "option",
    id = "crow_velocity_range",
    name = "velocity range",
    options = {"0-10V", "+/-5V"},
    action = function(val)
      velocity_offset_v = val and 0 or -5
    end,
  }

  params:add{
    type = "option",
    id = "crow_cc_range",
    name = "cc range",
    options = {"0-10V", "+/-5V"},
    actions = function(val)
      cc_offset_v = val and 0 or -5
    end,
  }

  params:add{
    type = 'option',
    id = 'crow_pitch_in',
    name = 'pitch in',
    options = {"off", "on"},
    action = function(val)
      if val == 1 then
        crow.input[1].mode('none')
      else
        crow.input[1].mode('stream', 0.01)
      end
    end,
  }

  params:add{
    type='option',
    id = 'crow_gate_out',
    name = 'gate out',
    options = {'gate', 'trig'},
    action = function(val)
      crow.output[1].volts = 0
      if val == 2 then
        crow.output[1].action = "pulse(0.005, 10)"
      end
    end
  }
end

function CrowControl.note_on(note_v, vel_v)
  if params:get("crow_gate_out") == 1 then
    crow.output[1].volts = 10
  else
    crow.output[1]()
  end
  crow.output[2].volts = note_v + note_offset_v
  crow.output[3].volts = vel_v + velocity_offset_v
end

function CrowControl.note_off()
  if params:get("crow_gate_out") == 1 then
    crow.output[1].volts = 0
  end
end

function CrowControl.cc(cc_v)
  crow.output[4].volts = cc_v + cc_offset_v
end

return CrowControl
