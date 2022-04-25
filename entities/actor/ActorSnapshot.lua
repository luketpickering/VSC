require "Object"

require "entities/actor/ActorStates"

local vector = require "hump/vector"

ActorSnapshot = Object:new {
  state = ActorStates.UNITINIALIZED,
  health = 0,
  DEAD_timer = 0,
  STUNNED_timer = 0,
  pos = vector(),
  vel = vector()
}

function ActorSnapshot:Interpolate(fraction, other_snap)
  local interpolated = ActorSnapshot:new{}

  interpolated.state = self.state
  interpolated.pos = self.pos + ((other_snap.pos - self.pos) * fraction)
  interpolated.vel = self.vel + ((other_snap.vel - self.vel) * fraction)
  interpolated.health = math.floor((self.health + ((other_snap.health - self.health) * fraction)) + 0.5)
  interpolated.DEAD_timer = self.DEAD_timer + ((other_snap.DEAD_timer - self.DEAD_timer) * fraction)
  interpolated.STUNNED_timer = self.STUNNED_timer + ((other_snap.STUNNED_timer - self.STUNNED_timer) * fraction)

  return interpolated
end