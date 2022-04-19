require "entities/Character"
require "AI/AI"

local vector = require "hump/vector"

local Baddie_ALIVE = {}
function Baddie_ALIVE.Command(self, command, value)
  if command == AICommands.NOTIFY_TARGET then
    self.MOVE_vector = value
  elseif (command == Commands.REWIND) and (value > 0) then
    self.next_state = DynamicBodyStates.REWINDING
    self.MOVE_vector = vector()
  end
end

function Baddie_ALIVE.Update(self, dt)
  local delta_control_vector = self.MOVE_vector 
    - self:GetVel()/self.control_velocity
  self.body:applyLinearImpulse( 
    (delta_control_vector * self.control_velocity):unpack() )
end

Baddie = Character:new{}
function Baddie:init(...)
  Character.init(self, ...)

  self.control_velocity = 30
  self.stunned_time = 1.25

  self.FSM[DynamicBodyStates.ALIVE] = Baddie_ALIVE

end