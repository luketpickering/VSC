require "Object"

require "control/commands"
require "control/Joystick"
require "control/Keyboard"

ControlTypes = {
  KEYBOARD = 100001,
  JOYSTICK = 100002
}

local ControlTypes_rev = { }
ControlTypes_rev[100001] = "KEYBOARD"
ControlTypes_rev[100002] = "JOYSTICK"

function ControlTypes.tostring(type)
  return ControlTypes_rev[type]
end

Control = Object:new{
	Recievers = {},
  Controllable = {},
  Translations = {},
}

function Control:init(itype)
  self.itype = itype or ControlTypes.KEYBOARD

  if self.itype == ControlTypes.KEYBOARD then
    self.Controllable = Keyboard:new{} 
    self.Translations = {
      z = Commands.ZOOM,
      r = Commands.REWIND
    }
  elseif self.itype == ControlTypes.JOYSTICK then
    self.Controllable = Joystick:new{}
    self.Translations = {
      left = Commands.MOVE,
      right = Commands.MOVE_CAMERA,
      triggerright = Commands.ZOOM
    }
  end
end

function Control:Command(command, value)
  if self.Recievers[Commands.ANY] then
    for _, r in ipairs(self.Recievers[Commands.ANY]) do
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
  commands = commands or Commands.ANY
  if type(commands) == "number" then
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