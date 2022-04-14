Commands = {
  MOVE=1,
  MOVE_CAMERA=2,
  REWIND=3,
  ZOOM=4,
  ANY=5
}

local Commands_rev = {
  "MOVE",
  "MOVE_CAMERA",
  "REWIND",
  "ZOOM",
  "ANY"
}

function Commands.tostring(com)
  return Commands_rev[com]
end
