require "Object"

require "control/Commands"

require "entities/actor/ActorStates"

local vector = require "hump/vector"

local MAX_REWIND_SPEED = 5

REWINDING = Object:new{}

function REWINDING.Enter(actor)
  actor.rewind_speed = 1
  actor.rewind_tick = 0

  --disable the physics engine for rewinding bodies
  actor.body:setActive(false)
  actor.BeganRewind = true
end

function REWINDING.Command(actor, command, value)
  if (command == Commands.MOVE) then
    actor.MOVE_vector = value
  elseif (command == Commands.REWIND) and (value < 1) then
    actor.next_state = ActorStates.POST_REWIND
  end
end

function REWINDING.Update(actor, dt)
  local rewind_dt = dt * actor.rewind_speed

  actor:RewindUpdate(rewind_dt)

  -- TODO: Want to tween rewind speed so that it slows down when the buffers are close to empty
  actor.rewind_tick = actor.rewind_tick + dt
  if actor.rewind_tick > 0.2 then
    actor.rewind_tick = 0
    actor.rewind_speed = math.min(actor.rewind_speed + 1, MAX_REWIND_SPEED)
  end

  -- If we've used up all of the state, lets go back
  if actor:GetNSnaps() == 0 then
    actor.next_state = ActorStates.POST_REWIND
  end
end

function REWINDING.Exit(actor)
  if actor.post_rewind_state then
    actor.next_state = actor.post_rewind_state
    actor.post_rewind_state = nil
  end

  actor.FinishedRewind = true
end

POST_REWIND = Object:new{}
function POST_REWIND.Enter(actor)
  assert(false)
end