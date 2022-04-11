require "Object"

require "graphics/Camera"

require "assets/Assets"

vector = require "hump/vector"

Background = Object:new{}

function Background:init()
  self.leaves = Graphics:GetTilesetQuad(13, 6)
  self.grass = Graphics:GetTilesetQuad(5, 0)
end

function Background:Draw(world_pos, min_pos)
  local tile_size = Assets.size

  local origin_tiles = (min_pos / tile_size):floor()
  local ntiles = (2 * (world_pos - min_pos)/tile_size):ceil()

  for i = 1, ntiles.x do
    for j = 1, ntiles.y do
      local abspos = origin_tiles + vector(i,j) 
      local chooser = ((103*abspos.x + 83 * abspos.y) % 59)
      if chooser == 58 then
        Graphics:DrawTilesetQuad(self.grass, (abspos*tile_size):unpack())
      elseif chooser == 57 then
        Graphics:DrawTilesetQuad(self.leaves, (abspos*tile_size):unpack())        
      end
    end
  end

  local max_pos = (origin_tiles + ntiles) * tile_size
  local origin_pos = origin_tiles * tile_size
  local width = max_pos - origin_pos
  Graphics:PushColor({1,0,0})
  love.graphics.rectangle("line", min_pos.x-tile_size/2, min_pos.y-tile_size/2, width.x, width.y)
  Graphics:PopColor()

end