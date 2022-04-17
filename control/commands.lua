Commands = {
  MOVE=10001,
  MOVE_CAMERA=10002,
  REWIND=10003,
  ZOOM=10004,
  ANY=10005
}

local Commands_rev = { }
Commands_rev[10001] = "MOVE"
Commands_rev[10002] = "MOVE_CAMERA"
Commands_rev[10003] = "REWIND"
Commands_rev[10004] = "ZOOM"
Commands_rev[10005] = "ANY"


function Commands.tostring(com)
  return Commands_rev[com]
end
