require "Object"

require "control/Joystick"
require "control/Keyboard"

Control = Object:new{
	Recievers = {},
  Controllable = {},
  Translations = {}
}

function Control:init(itype)
  self.itype = itype or "keyboard"

  if self.itype == "keyboard" then
    self.Controllable = Keyboard:new{} 
    self.Translations = {
      z = "zoom",
      r = "rewind"
    }
  elseif self.itype == "joystick" then
    self.Controllable = Joystick:new{}
    self.Translations = {
      left = "move",
      right = "move_camera",
      triggerright = "zoom"
    }
  end
end

function Control:Command(command, value)
  if self.Recievers["all"] then
    for _, r in ipairs(self.Recievers["all"]) do
      r:Command(command, value)
    end
  end
  if self.Recievers[command] then
    for _, r in ipairs(self.Recievers[command]) do
      r:Command(command, value)
    end
  end
end

function Control:Register(obj, commands)
  commands = commands or "all"
  if type(commands) == "string" then
    self.Recievers[commands] = self.Recievers[commands] or {}
    table.insert(self.Recievers[commands], obj)
  elseif type(commands) == "table" then
    for _, c in ipairs(commands) do
      self.Recievers[c] = self.Recievers[c] or {}
      table.insert(self.Recievers[c], obj)
    end
  end
end

function Control:Poll()
  local state_changes = self.Controllable:Poll()

  for _, input in ipairs(state_changes) do
    if self.Translations[input[1]] then
      input[1] = self.Translations[input[1]]
    end
    self:Command(input[1], input[2])
  end
end