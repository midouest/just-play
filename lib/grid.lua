local Grid = {}

local key_callback
local keys
local device

function Grid.init(callback)
  key_callback = callback
  keys = {}

  for y = 1, 8 do
    local row = {}
    for x = 1, 16 do
      row[x] = false
    end
    keys[y] = row
  end
end

function Grid.connect(input)
  grid.cleanup()
  device = grid.connect(input)
  device.key = handle_grid_key
end

local function handle_grid_key(x, y, z)
  keys[y][x] = z == 1
  key_callback(x, y, z)
end

function Grid.redraw(scale)
  device:all(0)

  for y = 1, 8 do
    for x = 1, 16 do
      local base = scale[y][x]
      device:led(x, y, keys[y][x] and 15 or base)
    end
  end

  device:refresh()
end

return Grid
