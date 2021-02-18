local Helpers = {}

-- Convert MIDI note to v/oct
-- @param n MIDI note (0-127)
function Helpers.n2v(n)
  return n / 12
end

function Helpers.v2n(v)
  return 12 * v
end

-- Convert a MIDI CC value to v/oct
-- @param cc MIDI CC value (0-127)
function Helpers.cc2v(cc)
  return (cc / 127) * 10
end

return Helpers
