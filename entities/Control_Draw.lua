require "entities/Player"
require "graphics/UI/Button"
require "graphics/UI/Radial"
require "graphics/UI/Bar"

local alpha = 0.5

Control_Draw = Player:new{ 
  x = Button_circ:new{ x = 450, 
                  y = 200, 
                  r = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0,0,1, alpha},  
                }, 
  y = Button_circ:new{ x = 550, 
                  y = 100, 
                  r = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {1,1,0, alpha},  
                }, 
  a = Button_circ:new{ x = 550, 
                  y = 300, 
                  r = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0,1,0, alpha},  
                }, 

  b = Button_circ:new{ x = 650, 
                  y = 200, 
                  r = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {1,0,0, alpha},  
                },
  dpup = Button_rect:new{ x = 100, 
                  y = 450, 
                  w = 30,
                  h = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  dpdown = Button_rect:new{ x = 100, 
                  y = 550, 
                  w = 30,
                  h = 50, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  dpleft = Button_rect:new{ x = 50, 
                  y = 500, 
                  w = 50,
                  h = 30, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  dpright = Button_rect:new{ x = 150, 
                  y = 500, 
                  w = 50,
                  h = 30, 
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  leftshoulder = Button_rect:new{ x = 50, 
                        y = 150, 
                        w = 40,
                        h = 15,
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  rightshoulder = Button_rect:new{ x = 750, 
                        y = 150, 
                        w = 40,
                        h = 15,
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  start = Button_rect:new{ x = 450, 
                        y = 150, 
                        w = 40,
                        h = 15,
                  bc = {0.9, 0.9, 0.9, alpha}, 
                  fc = {0.2,0.2,0.2, alpha},  
                },
  buttons = { 
    "x", 
    "y", 
    "a", 
    "b", 
    "dpup",
    "dpdown",
    "dpleft",
    "dpright",
    "leftshoulder",
    "rightshoulder",
    "start"},

  left_stick = Radial:new{x = 50, 
                          y = 150, 
                          r = 100, 
                          bc = {0.9, 0.9, 0.9, alpha}, 
                          fc = {0.2,0.2,0.2, alpha}, 
                         },

  right_stick = Radial:new{x = 250, 
                           y = 300, 
                           r = 100, 
                           bc = {0.9, 0.9, 0.9, alpha}, 
                           fc = {0.2,0.2,0.2, alpha}, 
                          },

  triggerleft = Bar:new{x = 50, 
                        y = 75, 
                        w = 40,
                        h = 100,
                        bc = {0.9, 0.9, 0.9, alpha}, 
                        fc = {0.2,0.2,0.2, alpha}, 
                       },

  triggerright = Bar:new{x = 750, 
                         y = 75, 
                         w = 40,
                         h = 100, 
                         bc = {0.9, 0.9, 0.9, alpha}, 
                         fc = {0.2,0.2,0.2, alpha}, 
                        },
}

function Control_Draw:Command(command, value)

  if self[command] and (type(value) == "boolean") then
    if value then 
      self[command]:Press() 
    else 
      self[command]:Release() 
    end
  end

  if command == "left" then
    self.left_stick:Set(value)
  end

  if command == "right" then
    self.right_stick:Set(value)
  end

    if command == "triggerleft" then
    self.triggerleft:Set(value)
  end

  if command == "triggerright" then
    self.triggerright:Set(value)
  end
end

function Control_Draw:Draw()

  for i, button in ipairs(self.buttons) do
    self[button]:Draw()
  end

  self.left_stick:Draw()
  self.right_stick:Draw()

  self.triggerleft:Draw()
  self.triggerright:Draw()
end