require "Object"

Assets = Object:new()

function Assets:init()
  self.ts = love.graphics.newImage("assets/colored-transparent.png")
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