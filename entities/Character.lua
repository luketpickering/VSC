require "Object"
require "physics/DynamicBody"

local vector = require "hump/vector"

Character = DynamicBody:new{}

function Character:init(world, character_assets, pos)
  pos = pos or vector()

  DynamicBody.init(self, love.physics.newBody(world, pos.x, pos.y, "dynamic"))

  self.quad = character_assets.quad
  self.shape = love.physics.newRectangleShape(character_assets.size, 
    character_assets.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)
end

function Character:Update(dt)
  DynamicBody.Update(self, dt)
end

function Character:Draw()
  Graphics:DrawTilesetQuad(self.quad, self:GetPos():unpack())
end