require "entities/actor/Actor"

Wizard = Actor:new{}
function Wizard:init(...)
  Actor.init(self, ...)
  self.name = "Wizard"

  self.control_velocity = 40
  self.stunned_time = 1.25

  self.Resistances[DamageTypes.PHYSICAL] = 1.5

end