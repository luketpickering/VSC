require "entities/Character"

local vector = require "hump/vector"

require "graphics/Graphics"

require "utils/console"

local Wizard_ALIVE = {}
function Wizard_ALIVE.Command(self, command, value)
  if (command == Commands.MOVE) then
    self.MOVE_vector = value
  elseif (command == Commands.REWIND) and (value > 0) then
    self.next_state = DynamicBodyStates.REWINDING
  end
end

function Wizard_ALIVE.Update(self, dt)
  local delta_control_vector = self.MOVE_vector 
    - self:GetVel()/self.control_velocity
  self.body:applyLinearImpulse( 
    (delta_control_vector * self.control_velocity):unpack() )
end

Wizard = Character:new{}
function Wizard:init(...)
  Character.init(self, ...)

  self.Resistances[DamageTypes.PHYSICAL] = 1.5

  self.control_velocity = 40

  self.FSM[DynamicBodyStates.ALIVE] = Wizard_ALIVE

end
