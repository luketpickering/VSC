require "Object"

require "control/Commands"

AI = Object:new{
  managed = {}
}

function AI:Attach(obj)
  table.insert(self.managed, obj)
end

function AI:Update(pc)

  for _, obj in ipairs(self.managed) do
    obj:Command(Commands.MOVE, 
      (pc:GetPos() - obj:GetPos()):normalized())
  end

end

function AI:Command(command, value)
  for _, obj in ipairs(self.managed) do
    obj:Command(command, value)
  end
end