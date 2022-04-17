require "Object"

Assets = Object:new{
  to_load = {
    KENNEY_SPRITES = { 
      file = "assets/kenney/colored-transparent.png", 
      size = 16,
      pad = 1,
    },
    VRYELL_UI_KB = { 
      file = "assets/vryell/kb_light_all.png", 
      size = 16,
      pad = 0,
    },
    VRYELL_UI_CTRLR = { 
      file = "assets/vryell/controller_minimal.png", 
      size = 16,
      pad = 0,
    },
  },
  FONT = {},
}


function Assets:init()

  for name, descriptor in pairs(self.to_load) do
    self[name] = {
     ss = love.graphics.newImage(descriptor.file),
     size = descriptor.size,
     pad = descriptor.pad,
    }
    self[name].w = self[name].ss:getWidth()
    self[name].h = self[name].ss:getHeight()
  end
  
  self.FONT[12] = love.graphics.newFont("assets/kenney/kenney_blocks.ttf", 12)
  self.FONT[20] = love.graphics.newFont("assets/kenney/kenney_blocks.ttf", 20)

end

function Assets:Quad(sprite_sheet, nx, ny)
  return love.graphics.newQuad(
    nx*(self[sprite_sheet].size + self[sprite_sheet].pad),
    ny*(self[sprite_sheet].size + self[sprite_sheet].pad), 
    self[sprite_sheet].size, self[sprite_sheet].size, 
    self[sprite_sheet].w, self[sprite_sheet].h)
end

function Assets:GetSprite(sprite_sheet, nx, ny)
  return {
    sprite_sheet = sprite_sheet,
    quad = self:Quad(sprite_sheet, nx, ny),
    size = self[sprite_sheet].size
  }
end