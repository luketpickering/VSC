require "Object"

require "entities/actor/DamageTypes"
require "entities/actor/damage"

require "entities/actor/ActorStates"
require "entities/actor/ActorSnapshot"

require "entities/actor/states/ALIVE"
require "entities/actor/states/REWINDING"
require "entities/actor/states/STUNNED"
require "entities/actor/states/DEAD"

require "physics/RewindableBody"

local vector = require "hump/vector"

Actor = RewindableBody:new{}

function Actor:init_physics(world, pos)
  pos = pos or vector()
  
  RewindableBody.init(self, 
    love.physics.newBody(world, pos.x, pos.y, "dynamic"))

  self.shape = love.physics.newCircleShape(self.sprite.size/2)
  self.fixture = love.physics.newFixture(self.body, self.shape, 0.1)
  self.fixture:setUserData(self)

  self.body:setMass(1) --kg
  self.body:setLinearDamping(2)

end

function Actor:init_properties()
  self.max_health = 30
  self.health = self.max_health

  self.control_velocity = 30
  self.STUNNED_timer = 1

  self.Resistances = {}
  self.Resistances[DamageTypes.PHYSICAL] = 1
  self.Resistances[DamageTypes.MAGIC] = 1

  self.Heals = {}
  self.Hurts = {}
  self.Stuns = {}
  self.Shoves = {}

  -- Here we can read subclass properties from config files
end

function Actor:init_FSM()
  self.FSM = {}
  
  self.FSM[ActorStates.ALIVE] = ALIVE
  self.FSM[ActorStates.REWINDING] = REWINDING
  self.FSM[ActorStates.POST_REWIND] = POST_REWIND
  self.FSM[ActorStates.STUNNED] = STUNNED
  self.FSM[ActorStates.DEAD] = DEAD

  self.state = ActorStates.UNITINIALIZED
  self.next_state = ActorStates.ALIVE
end

function Actor:init_sprite(sprite)
  self.sprite = sprite
end

function Actor:init(sprite, world, pos)
  self:init_properties()
  self:init_sprite(sprite)
  self:init_physics(world, pos)
  self:init_FSM()
end

function Actor:Command(command, value)

  if self.FSM[self.state] and self.FSM[self.state].Command then
    self.FSM[self.state].Command(self, command, value)
  end
end

function Actor:Update(dt)
  self:ApplyHeals()
  self:ApplyHurts()
  self:ApplyStuns()
  self:ApplyShoves()

  self.BeganRewind = false
  self.FinishedRewind = false

  if self.FSM[self.state] and self.FSM[self.state].Update then
    self.FSM[self.state].Update(self, dt)
  end

  -- If we need to transition state, do so
  if self.next_state then

    if self.next_state == ActorStates.POST_REWIND then
      io.write(string.format("%s state transition(PR) %s -> %s\n", self.name, 
        ActorStates.tostring(self.state),
        ActorStates.tostring(self.next_state)))
    end

    if self.FSM[self.state] and self.FSM[self.state].Exit then
      self.FSM[self.state].Exit(self)
    end

    io.write(string.format("%s state transition %s -> %s\n", self.name, 
      ActorStates.tostring(self.state),
      ActorStates.tostring(self.next_state)))

    self.state = self.next_state
    self.next_state = nil

    if self.FSM[self.state] and self.FSM[self.state].Enter then
      self.FSM[self.state].Enter(self)
    end

    return self.state
  end

  return nil
end

function Actor:TakeSnapshot()
  local snap = ActorSnapshot:new{}
  snap.pos = self:GetPos()
  snap.vel = self:GetVel()
  snap.state = self.state
  snap.health = self.health
  return snap
end

function Actor:Heal(x)
  table.insert(self.Heals, {x=x})
end

function Actor:Hurt(x, dtype)
  dtype = dtype or DamageTypes.PHYSICAL
  table.insert(self.Hurts, {x=x, dtype=dtype})
end

function Actor:Stun(x, dtype)
  dtype = dtype or DamageTypes.PHYSICAL
  table.insert(self.Stuns, {x=x, dtype=dtype})
end

function Actor:Shove(xy, dtype)
  dtype = dtype or DamageTypes.PHYSICAL
  table.insert(self.Shoves, {xy=xy, dtype=dtype})
end

function Actor:ApplyHeals()
  for _, h in ipairs(self.Heals )do
    Heal(self, h.x)
  end
  self.Heals = {}
end

function Actor:ApplyHurts()
  for _, h in ipairs(self.Hurts )do
    Hurt(self, h.x, h.dtype)
  end
  self.Hurts = {}
end

function Actor:ApplyStuns()
  for _, s in ipairs(self.Stuns )do
    Stun(self, s.x, s.dtype)
  end
  self.Stuns = {}
end

function Actor:ApplyShoves()
  for _, s in ipairs(self.Shoves) do
    Shove(self, s.xy, s.dtype)
  end
  self.Shoves = {}
end

function Actor:RevertToSnapshot(snap)
  if not snap then return end

  self:SetPos(snap.pos)
  self:SetVel(snap.vel)
  self.health = snap.health
  self.post_rewind_state = snap.state
end

function Actor:Draw()
  if self.state < ActorStates.DEAD then
    Graphics:DrawSprite(self.sprite, self:GetPos():unpack())
  end
end