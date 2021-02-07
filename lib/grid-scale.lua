local musicutil = require 'musicutil'

local GridScale = {}

-- Offset in semitones between each row of the grid
GridScale.ROW_OFFSET = 5

-- Override the chromatic mask instead of lighting every single LED
GridScale.CHROMATIC_MASK = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

function GridScale.to_note(x, y)
  return ((8 - y) * GridScale.ROW_OFFSET) + x - 1 + params:get("grid_min_note")
end

-- Generate a 2-dimensional array of Grid LED brightness levels for the given
-- scale
-- @param scale Integer ID of the scale used to generate the LED pattern. See
--        MusicUtil.SCALES for possible values
-- @param diatonic_level LED brightness level for diatonic notes
-- @param octave_level LED brightness level for octaves of the root note
function GridScale.generate_grid(scale, diatonic_level, octave_level)
  local scale_mask = GridScale.CHROMATIC_MASK
  if scale ~= #musicutil.SCALES then
    local scale_array = musicutil.generate_scale(0, scale)
    scale_mask = generate_scale_mask(scale_array)
  end

  local grid = {}
  for y = 1, 8 do
    local offset = (8 - y) * GridScale.ROW_OFFSET
    local row = generate_row(offset, scale_mask, diatonic_level, octave_level)
    grid[y] = row
  end
  return grid
end

-- Generate a mask of 1s and 0s for the given scale where 1s represent
-- diatonic notes and 0s represent non-diatonic notes
-- @param scale_array Array of notes diatonic to the scale
local function generate_scale_mask(scale_array)
  local mask = {}
  local i = 1
  while #mask < 12 do
    if #mask == scale_array[i] then
      table.insert(mask, 1)
      i = i + 1
    else
      table.insert(mask, 0)
    end
  end
  return mask
end

-- Generate the LED brightness values for a single grid row using the given
-- scale
-- @param offset Offset in semitones of the first note in the row
-- @param scale_mask Mask of 1s and 0s where 1s represent diatonic notes and 0s
--        represent non-diatonic notes
-- @param diatonic_level LED brightness level for diatonic notes
-- @param octave_level LED brightness level for octaves of the root note
local function generate_row(offset, scale_mask, diatonic_level, octave_level)
  local row = {}
  for i = 1, 16 do
    local note = (offset + i - 1) % 12
    if scale_mask[note + 1] == 1 then
      row[i] = note == 0 and octave_level or diatonic_level
    else
      row[i] = 0
    end
  end
  return row
end

return GridScale
