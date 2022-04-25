require "Object"

require "entities/actor/ActorStates"

local vector = require "hump/vector"

DEAD = Object:new{}
function DEAD.Enter(actor)
  actor.body:setActive(false)
end

function DEAD.Command(actor, dt)
  if (command == Commands.REWIND) and (value > 0) then
    actor.next_state = ActorStates.REWINDING
  end
end

function DEAD.Update(actor, dt)

  --if all of the states in the snapshot history are dead, then its time for GC
  local last_snap = actor:PeekSnap()
  if last_snap and (last_snap.state == ActorStates.DEAD) then
    actor.next_state = ActorStates.READY_FOR_GC
  else 
    actor:RecordUpdate(dt)
  end
end