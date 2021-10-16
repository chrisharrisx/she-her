tracks = include('lib/tracks')

local GridUtil = {}

function GridUtil.update_trigs(g)
  for y = 1, 4 do
    trigs = tracks[y]:get_steps()
    position = tracks[y]:get_position()
    
    for x = 1, #trigs do
      val = (x == position and trigs[x] and 15) or (x == position and not trigs[x] and 8) or trigs[x] and 6 or 3
      g:led(x, y, val)
    end
    if #trigs < 16 then
      for x = #trigs, 16 do
        g:led(x, y, 0)
      end
    end
  end
  g:refresh()
end

function GridUtil.update_mutes(g)
  y = 8
  for x = 1, 4 do
    g:led(x, y, tracks[x]:get_fixed_velocity() > 0 and 6 or 3)
  end
  g:refresh()
end

function GridUtil.init(g)
  GridUtil.update_mutes(g)
end

return GridUtil