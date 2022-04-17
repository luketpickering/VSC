require "entities/Character"

local vector = require "hump/vector"

require "graphics/Graphics"

require "utils/console"

Wizard = Character:new { 
  maxVel = 50,
}

function Wizard:Command(command, value)

  if self.state < DynamicBodyStates.READY_FOR_GC then
    
    if (command == Commands.MOVE) 
      and (self.state == DynamicBodyStates.ALIVE_RECORDING) then
      self.body:setLinearVelocity( (value * self.maxVel):unpack() )
    elseif command == Commands.REWIND then
      self.next_state = (value > 0) and 
            DynamicBodyStates.REWINDING or
            DynamicBodyStates.ALIVE_RECORDING
    end

  end
end