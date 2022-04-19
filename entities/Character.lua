require "Object"

require "entities/damage"

require "physics/DynamicBody"

local vector = require "hump/vector"

Character = DynamicBody:new{}

local Character_REWINDING = {}
function Character_REWINDING.Enter(self)
  self.MOVE_vector = vector()
end
function Character_REWINDING.Command(self, command, value)
  if (command == Commands.MOVE) then
    self.MOVE_vector = value
  elseif (command == Commands.REWIND) and (value < 1) then
    self.next_state = DynamicBodyStates.ALIVE
  end

  if (self.fine_state_history:Size() + 
      self.coarse_state_history:Size()) == 0 then
    self.next_state = DynamicBodyStates.ALIVE
  end
end

local Character_STUNNED = {}
function Character_STUNNED.Enter(self)
  self.MOVE_vector = vector()
end

function Character_STUNNED.Command(self, command, value)
  if (command == Commands.MOVE) then
    self.MOVE_vector = value
  end
end

function Character_STUNNED.Update(self, dt)
  self.STUNNED_timer = self.STUNNED_timer - dt

  if self.STUNNED_timer <= 0 then
    self.next_state = DynamicBodyStates.ALIVE
  end
end

function Character:Heal(x)
  self.health = math.floor(math.min(self.max_health, self.health + x) + 0.5)
end

function Character:Hurt(x, dtype)
  dtype = dtype or DamageTypes.PHYSICAL
  self.health = math.floor((self.health - x / self.Resistances[dtype]) + 0.5)
end

function Character:init(world, sprite, pos)
  pos = pos or vector()
  self.MOVE_vector = vector()
  self.control_velocity = 30
  self.stunned_time = 1
  self.max_health = 30
  self.health = self.max_health

  self.Resistances = {}
  self.Resistances[DamageTypes.PHYSICAL] = 1
  self.Resistances[DamageTypes.MAGIC] = 1

  DynamicBody.init(self, love.physics.newBody(world, pos.x, pos.y, "dynamic"))
  self.next_state = DynamicBodyStates.ALIVE
  
  self.sprite = sprite
  self.shape = love.physics.newCircleShape(sprite.size/2)
  self.fixture = love.physics.newFixture(self.body, self.shape, 0.1)
  self.fixture:setUserData(self)

  self.body:setMass(1) --kg
  self.body:setLinearDamping(2)

  self.FSM[DynamicBodyStates.ALIVE] = Character_ALIVE
  self.FSM[DynamicBodyStates.REWINDING] = Character_REWINDING
  self.FSM[DynamicBodyStates.STUNNED] = Character_STUNNED
end

function Character:Command(command, value)
  if self.FSM[self.state] and self.FSM[self.state].Command then
    self.FSM[self.state].Command(self, command, value)
  end
end

function Character:Update(dt)
  if self.health <= 0 then
    self.next_state = DynamicBodyStates.DEAD
  end

  if self.FSM[self.state] and self.FSM[self.state].Update then
    self.FSM[self.state].Update(self, dt)
  end

  DynamicBody.Update(self, dt)
end

function Character:Draw()
  if self.state < DynamicBodyStates.DEAD then
    Graphics:DrawSprite(self.sprite, self:GetPos():unpack())
  end
end