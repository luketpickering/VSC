require "Object"

require "assets/Assets"

require "control/commands"

require "graphics/Graphics"

kb = Object:new{}

function kb:init(window)
  self.sprites = {
    MOVE_LEFT = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 0),
      Assets:GetSprite("VRYELL_UI_KB", 1, 0),
      vector(28,window.height - 70)
    },

    MOVE_RIGHT = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 3),
      Assets:GetSprite("VRYELL_UI_KB", 1, 3),
      vector(52, window.height - 70)
    },

    MOVE_UP = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 22),
      Assets:GetSprite("VRYELL_UI_KB", 1, 22),
      vector(38, window.height - 84)
    },

    MOVE_DOWN = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 18),
      Assets:GetSprite("VRYELL_UI_KB", 1, 18),
      vector(40, window.height - 70)
    },

    REWIND = {
      Assets:GetSprite("VRYELL_UI_KB", 0, 17),
      Assets:GetSprite("VRYELL_UI_KB", 1, 17),
      vector(58,window.height - 84)
    },

    ZOOM = {
      Assets:GetSprite("VRYELL_UI_KB", 0, 25),
      Assets:GetSprite("VRYELL_UI_KB", 1, 25),
      vector(36, window.height - 56)
    },

    MOVE_CAMERA_LEFT = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 9),
      Assets:GetSprite("VRYELL_UI_KB", 1, 9),
      vector(window.width - 64,window.height - 60)
    },

    MOVE_CAMERA_RIGHT = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 11),
      Assets:GetSprite("VRYELL_UI_KB", 1, 11),
      vector(window.width - 40, window.height - 60)
    },

    MOVE_CAMERA_UP = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 8),
      Assets:GetSprite("VRYELL_UI_KB", 1, 8),
      vector(window.width - 50, window.height - 74)
    },

    MOVE_CAMERA_DOWN = { 
      Assets:GetSprite("VRYELL_UI_KB", 0, 10),
      Assets:GetSprite("VRYELL_UI_KB", 1, 10),
      vector(window.width - 52, window.height - 60)
    },
  }
  self.states = {}
end

function kb:Command(command, value)
  if command == Commands.MOVE then
    self.states.MOVE_RIGHT = (value.x > 0)
    self.states.MOVE_LEFT = (value.x < 0)

    self.states.MOVE_DOWN = (value.y > 0)
    self.states.MOVE_UP = (value.y < 0)
  elseif command == Commands.MOVE_CAMERA then
    self.states.MOVE_CAMERA_RIGHT = (value.x > 0)
    self.states.MOVE_CAMERA_LEFT = (value.x < 0)

    self.states.MOVE_CAMERA_DOWN = (value.y > 0)
    self.states.MOVE_CAMERA_UP = (value.y < 0)
  elseif command == Commands.REWIND then
    self.states.REWIND = (value > 0)
  elseif command == Commands.ZOOM then
    self.states.ZOOM = (value > 0)
  end
end

function kb:Draw()
  for k, spr in pairs(self.sprites) do
    if self.states[k] then
      Graphics:DrawSprite(spr[2], spr[3]:unpack())
    else
      Graphics:DrawSprite(spr[1], spr[3]:unpack())
    end
  end
end