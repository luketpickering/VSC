require "Object"

require "assets/Assets"

Graphics = Object:new{}

function Graphics:init()
  Assets:init()
end

function Graphics:GetTilesetQuad(x, y)
  return Assets:GetTilesetQuad(x, y)
end

function Graphics:DrawTilesetQuad(Q, x, y)
  love.graphics.draw(Assets.ts, Q, x, y)
end