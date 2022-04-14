require "Object"

Assets = Object:new()

function Assets:init()
  self.ts = love.graphics.newImage("assets/kenney/colored-transparent.png")
  self.Font = {}
  self.Font[12] = love.graphics.newFont("assets/kenney/kenney_blocks.ttf", 12)
  self.Font[20] = love.graphics.newFont("assets/kenney/kenney_blocks.ttf", 20)
  self.size = 16
  self.padding = 1

  self.ts_w = self.ts:getWidth()
  self.ts_h = self.ts:getHeight()

end

function Assets:GetTilesetQuad(x, y)
  return love.graphics.newQuad(x*(self.size + self.padding),
    y*(self.size + self.padding), self.size, self.size, 
    self.ts_w, self.ts_h)
end

function Assets:GetCharacterAssets(x,y)
  return {
    quad = self:GetTilesetQuad(x,y),
    size = self.size
  }
end