require "Object"

require "entities/actor/ActorStates"

local vector = require "hump/vector"

STUNNED = Object:new{}

function STUNNED.Enter(actor)
  actor.MOVE_vector = vector()
end

function STUNNED.Command(actor, command, value)
  if (command == Commands.MOVE) then
    actor.MOVE_vector = value
  elseif (command == Commands.REWIND) then
    actor.unstunned_next_state = (value > 0) and ActorStates.REWINDING 
                                             or nil
  end
end

function STUNNED.Update(actor, dt)
  actor.STUNNED_timer = actor.STUNNED_timer - dt

  if actor.STUNNED_timer <= 0 then
    actor.next_state = ActorStates.ALIVE
  end

  if actor.health <= 0 then
    actor.next_state = ActorStates.DEAD
  end

  actor:RecordUpdate(dt)
end

function STUNNED.Exit(actor)
  -- allows us to initiate rewinding in the same frame as become unstunned 
  -- if rewind was held while stunned
  if actor.unstunned_next_state then
    actor.next_state = actor.unstunned_next_state
  end
end