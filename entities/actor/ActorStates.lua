ActorStates = {
  ALIVE = 11,
  STUNNED = 12,
  REWINDING = 13,
  POST_REWIND = 14, -- dummy state to signal state transition, 
                    -- should never be Entered
  DEAD = 15,
  READY_FOR_GC = 16,
  UNITINIALIZED = 17,
}

local ActorStates_rev = { }
ActorStates_rev[11] = "ALIVE"
ActorStates_rev[12] = "STUNNED"
ActorStates_rev[13] = "REWINDING"
ActorStates_rev[14] = "POST_REWIND"
ActorStates_rev[15] = "DEAD"
ActorStates_rev[16] = "READY_FOR_GC"
ActorStates_rev[17] = "UNITINIALIZED"

function ActorStates.tostring(state)
  return ActorStates_rev[state]
end