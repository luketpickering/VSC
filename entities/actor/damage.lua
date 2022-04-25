require "entities/actor/DamageTypes"
require "entities/actor/ActorStates"

function Heal(actor, x)
  io.write(string.format("%s (H: %s, S: %s) healed for %s\n", 
    actor.name, actor.health,
    ActorStates.tostring(actor.state), x))
  actor.health = math.floor(math.min(actor.max_health, actor.health + x) + 0.5)
end

function Hurt(actor, x, dtype)
  local prevhealth = actor.health
  actor.health = math.floor((actor.health - x / actor.Resistances[dtype]) + 0.5)

  io.write(string.format("%s (H: %s, S: %s) takes %s damage of %s dealt by type %s (res: %s)\n", 
    actor.name, prevhealth,
    ActorStates.tostring(actor.state),
    prevhealth - actor.health,
    x, DamageTypes.tostring(dtype), actor.Resistances[dtype]))
end

function Stun(actor, x, dtype)
  actor.next_state = ActorStates.STUNNED

  -- being stunned again with a shorter stun can't reduce stunned time
  actor.STUNNED_timer = math.max(
    math.floor((x / actor.Resistances[dtype]) + 0.5),
    actor.STUNNED_timer)

  io.write(string.format("%s (H: %s, S: %s) is now stunned for %ss after being dealt %ss by type %s (res: %s)\n", 
    actor.name, actor.health,
    ActorStates.tostring(actor.state),
    actor.STUNNED_timer,
    x, DamageTypes.tostring(dtype), actor.Resistances[dtype]))
end

function Shove(actor, x, dtype)

  local shove_impulse = x/actor.Resistances[dtype]

  actor:GetBody():applyLinearImpulse(shove_impulse:unpack())

  io.write(string.format("%s (H: %s, S: %s) is shoved for %s after being dealt %s by type %s (res: %s)\n", 
    actor.name, actor.health,
    ActorStates.tostring(actor.state),
    shove_impulse,
    x, DamageTypes.tostring(dtype), actor.Resistances[dtype]))
end