require "entities/Character"
require "entities/AI"

local vector = require "hump/vector"

Baddie = Character:new { 
  maxVel = 40,
}

function Baddie:Command(command, value)

  if self.state < DynamicBodyStates.READY_FOR_GC then
    
    if (command == AICommands.NOTIFY_TARGET) 
      and (self.state == DynamicBodyStates.ALIVE_RECORDING) then
      self.body:setLinearVelocity( (value * self.maxVel):unpack() )
    elseif command == Commands.REWIND then
      self.next_state = (value > 0) and 
            DynamicBodyStates.REWINDING or
            DynamicBodyStates.ALIVE_RECORDING
    end

  end

end

function Baddie:Draw()
  Character.Draw(self)
end 