require "entities/Character"

local vector = require "hump/vector"

require "graphics/Graphics"

require "utils/console"

Wizard = Character:new { 
  maxVel = 50,
}

function Wizard:Command(command, value)
  io.write(string.format("Wizard Recieving: %s, %s", 
    Commands.tostring(command), value), "\n")

  if (command == Commands.MOVE) 
    and (self.state == DynamicBodyStates.ALIVE_RECORDING) then
    self.body:setLinearVelocity( (value * self.maxVel):unpack() )
  elseif command == Commands.REWIND then
    self.next_state = (value > 0) and 
          DynamicBodyStates.REWINDING or
          DynamicBodyStates.ALIVE_RECORDING
  end

end

function Wizard:Draw()
  Character.Draw(self)

  Graphics:PushColor({1,1,0})
  love.graphics.points(self.body:getX(), self.body:getY())
  love.graphics.rectangle("line",
    self.body:getX() - Assets.size/2, self.body:getY() - Assets.size/2, 
    Assets.size, Assets.size)
  Graphics:PopColor()

end 