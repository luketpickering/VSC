require "Object"

require "control/Commands"

require "entities/actor/ActorStates"

local vector = require "hump/vector"

ALIVE = Object:new{}

function ALIVE.Enter(actor)
  actor.body:setActive(true)
end

function ALIVE.Command(actor, command, value)
  if (command == Commands.MOVE) then
    actor.MOVE_vector = value
  elseif (command == Commands.REWIND) and (value > 0) then
    actor.next_state = ActorStates.REWINDING
  end
end

function ALIVE.Update(actor, dt)
  if actor.health <= 0 then
    actor.next_state = ActorStates.DEAD
  end

  local delta_control_vector =  
    ((actor.MOVE_vector or vector()) * actor.control_velocity)
                                  - actor:GetVel()

  local norm = math.min(delta_control_vector:len(), actor.control_velocity)
  delta_control_vector:normalizeInplace()

  actor.body:applyLinearImpulse( 
    (delta_control_vector * norm):unpack() )

  actor:RecordUpdate(dt)
end

function ALIVE.Exit(actor)
  actor.MOVE_vector = vector()
end