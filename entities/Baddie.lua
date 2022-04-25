require "entities/actor/Actor"

Baddie = Actor:new{}
function Baddie:init(...)
  Actor.init(self, ...)
  self.name = "Baddie"

  self.control_velocity = 30
  self.stunned_time = 1.25

end