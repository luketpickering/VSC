require "entities/Player"

local vector = require "hump/vector"

require "graphics/Graphics"

Baddie = Player:new{
  maxVel = 5
}

function Baddie:init(world, pos)
  pos = pos or vector(0,0)
  self.quad = Graphics:GetTilesetQuad(26, 2)
  self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  self.shape = love.physics.newRectangleShape(Assets.size, Assets.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function Baddie:Update()
end

function Baddie:Command(command, value)
  if self.body:getLinearVelocity() < self.maxVel then
    local pdir = (Wizard:GetPos() - self:GetPos())
    pdir:normalizeInplace()
    self.body:applyForce(pdir:unpack())
  end  
end

function Baddie:Draw()
  Graphics:DrawTilesetQuad(self.quad, self:GetPos():unpack())
end