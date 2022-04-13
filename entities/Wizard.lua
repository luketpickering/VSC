require "entities/Player"

local vector = require "hump/vector"

require "graphics/Graphics"

require "utils/console"

Wizard = Player:new { 
  maxVel = 50,
}

function Wizard:init(world, pos)
  pos = pos or vector(0,0)
  self.quad = Graphics:GetTilesetQuad(24, 1)
  self.body = love.physics.newBody(world, pos.x, pos.y, "dynamic")
  self.shape = love.physics.newRectangleShape(Assets.size, Assets.size)
  self.fixture = love.physics.newFixture(self.body, self.shape, 1)

  Player.init(self)

  console.print(self)
end

function Wizard:Command(command, value)
  io.write(string.format("Wizard Recieving: %s, %s", command, value), "\n")
  if command == "move" and self.state == "play" then
    self.body:setLinearVelocity( (value * self.maxVel):unpack() )

    self:StoreMove(value * self.maxVel)
  elseif command == "rewind" then
    self.next_state = value > 0 and "rewind" or "play"
  end
end

function Wizard:Draw()
  Graphics:DrawTilesetQuad(self.quad, self:GetPos():unpack())

  Graphics:PushColor({1,1,0})
  love.graphics.points(self.body:getX(), self.body:getY())
  love.graphics.rectangle("line",
    self.body:getX() - Assets.size/2, self.body:getY() - Assets.size/2, 
    Assets.size, Assets.size)
  Graphics:PopColor()
end 