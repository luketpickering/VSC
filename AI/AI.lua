require "Object"

AI = Object:new{
  managed = {}
}

AICommands = {
  NOTIFY_TARGET = 1001,
}
local AICommands_rev = {}
AICommands_rev[1001] = "NOTIFY_TARGET"

function AICommands.tostring(c)
  return AICommands_rev[c]
end

function AI:Attach(obj)
  table.insert(self.managed, obj)
end

function AI:Update(pc)

  for _, obj in ipairs(self.managed) do
    obj:Command(AICommands.NOTIFY_TARGET, 
      (pc:GetPos() - obj:GetPos()):normalized())
  end

end

function AI:Command(command, value)
  for _, obj in ipairs(self.managed) do
    obj:Command(command, value)
  end
end