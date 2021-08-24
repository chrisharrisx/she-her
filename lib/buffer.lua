local note = 1
local velocity = 2
local track = 3

local Buffer = {
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}
  }
}

Buffer.loop_types = {
  'clip',
  'regen'
}

Buffer.length = 64
Buffer.start = 1
Buffer.start_changed = 0
Buffer.loop = 0
Buffer.read_write_positions = { 1, 1, 1, 1 }
Buffer.loop_type = 0

function Buffer.write_buffer(track, event)
  if #event ~= 0 then
    table.remove(Buffer[track], Buffer.read_write_positions[track])
    table.insert(Buffer[track], Buffer.read_write_positions[track], event)
  else
    table.remove(Buffer[track], Buffer.read_write_positions[track])
    table.insert(Buffer[track], Buffer.read_write_positions[track], {})
  end
end

function Buffer.read_buffer(track)
  -- print(track, Buffer.read_write_positions[track], Buffer.start)
  return Buffer[track][Buffer.read_write_positions[track] + Buffer.start - 1]
end

function Buffer.advance(track, state)

    if Buffer.read_write_positions[track] < Buffer.length then
      Buffer.read_write_positions[track] = Buffer.read_write_positions[track] + 1
    else
      Buffer.read_write_positions[track] = 1
    end
  
end

function Buffer.get_read_position(track)
  return Buffer.read_write_positions[track]
end

function Buffer.getPulsesForTrack(track)
  count = 0
  for i = 1, #Buffer[track] do
    if Buffer[track][i] then
      count = count + 1
    end
  end
  return count
end

function Buffer.setPulsesForTrack(trackNum, steps)
  table.remove(Buffer, trackNum)
  table.insert(Buffer, trackNum, steps)
end

function Buffer.clear()
  start = Buffer.length + 1
  length = 64
  
  if start < length then
    for k = 1, #Buffer do
      for j = start, length do
        for i = 1, #Buffer[k][j] do 
          Buffer[k][j][i] = nil 
        end
      end
    end
  end
end

function Buffer.print()
  buffer_string = ''  
  
  for i = 1, #state.buffer do
    buffer_string = buffer_string .. "{"
    for j = 1, #state.buffer[i] do
      buffer_string = buffer_string .. "{"
      for k = 1, #state.buffer[i][j] do
        buffer_string = buffer_string .. state.buffer[i][j][k]
      end
      buffer_string = buffer_string .. "}"
    end
    buffer_string = buffer_string .. "}\n"
  end
  
  return buffer_string
end

return Buffer