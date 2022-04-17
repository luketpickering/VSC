require "Object"
require "physics/DynamicBody"

local vector = require "hump/vector"

Character = DynamicBody:new{}

function Character:init(world, sprite, pos)
  pos = pos or vector()

  DynamicBody.init(self, love.physics.newBody(world, pos.x, pos.y, "dynamic"))
  
  self.sprite = sprite
  self.shape = love.physics.newRectangleShape(sprite.size, sprite.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function Character:Update(dt)
  DynamicBody.Update(self, dt)
end

function Character:Draw()
  Graphics:DrawSprite(self.sprite, self:GetPos():unpack())
end