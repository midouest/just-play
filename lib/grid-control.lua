local MusicUtil = require('musicutil')

local GridScale = include('lib/grid-scale')

local GridControl = {}

local key_callback
local keys
local scale
local device

function GridControl.init(options)
  key_callback = options.on_key
  keys = {}

  for y = 1, 8 do
    local row = {}
    for x = 1, 16 do
      row[x] = false
    end
    keys[y] = row
  end
  params:add_separator("grid")

  params:add{
    type = "number",
    id = "grid_device",
    name = "device",
    min = 1,
    max = 4,
    default = 1,
    step = 1,
    action = GridControl.connect,
  }

  params:add{
    type = "number",
    id = "grid_velocity",
    name = "fixed velocity",
    min = 0,
    max = 127,
    step = 1,
    default = 64,
  }

  params:add{
    type = "number",
    id = "grid_min_note",
    name = "minimum note",
    min = 0,
    max = 127,
    step = 1,
    default = 48,
    formatter = function(control)
      return MusicUtil.note_num_to_name(control:get(), true)
    end,
  }

  params:add{
    type = "number",
    id = "grid_scale",
    name = "scale",
    min = 1,
    max = #MusicUtil.SCALES,
    step = 1,
    default = 1,
    formatter = function(control)
      local val = control:get()
      return MusicUtil.SCALES[val].name
    end,
    action = function(val)
      scale = GridScale.generate_grid(val, 3, 4)
      GridControl.redraw()
    end,
  }
end

local function handle_grid_key(x, y, z)
  keys[y][x] = z == 1
  key_callback(x, y, z)
  GridControl.redraw()
end

function GridControl.connect(input)
  grid.cleanup()
  device = grid.connect(input)
  device.key = handle_grid_key
end

function GridControl.to_note(x, y)
  return ((8 - y) * GridScale.ROW_OFFSET) + x - 1 + params:get("grid_min_note")
end

function GridControl.redraw()
  device:all(0)

  local notes = {}
  for y = 1, 8 do
    for x = 1, 16 do
      local note_on = keys[y][x]
      if note_on then
        table.insert(notes, {x = x, y = y})
      else
        device:led(x, y, scale[y][x])
      end
    end
  end

  for _, note in ipairs(notes) do
    local matching_notes = GridScale.find_matching_notes(note.x, note.y)
    for _, match in ipairs(matching_notes) do
      device:led(match.x, match.y, 6)
    end
    device:led(note.x, note.y, 15)
  end

  device:refresh()
end

return GridControl
