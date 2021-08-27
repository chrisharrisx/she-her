local note = 1
local velocity = 2
local track = 3

local Buffer = {}

Buffer.data = {
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
    table.remove(Buffer.data[track], Buffer.read_write_positions[track])
    table.insert(Buffer.data[track], Buffer.read_write_positions[track], event)
  else
    table.remove(Buffer.data[track], Buffer.read_write_positions[track])
    table.insert(Buffer.data[track], Buffer.read_write_positions[track], {})
  end
end

function Buffer.read_buffer(track)
  -- print(track, Buffer.read_write_positions[track], Buffer.start)
  return Buffer.data[track][Buffer.read_write_positions[track] + Buffer.start - 1]
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
  for i = 1, #Buffer.data[track] do
    if Buffer.data[track][i] then
      count = count + 1
    end
  end
  return count
end

function Buffer.setPulsesForTrack(trackNum, steps)
  table.remove(Buffer.data, trackNum)
  table.insert(Buffer.data, trackNum, steps)
end

function Buffer.clear()
  start = Bufferlength + 1
  length = 64
  
  if start < length then
    for k = 1, #Buffer.data do
      for j = start, length do
        for i = 1, #Buffer.data[k][j] do 
          Buffer.data[k][j][i] = nil 
        end
      end
    end
  end
end

function Buffer.load_buffer(new_buffer)
  Buffer.data = nil 
  Buffer.data = {}
  
  for i = 1, #new_buffer do
    Buffer.data[i] = {} -- track
    for j = 1, #new_buffer[i] do
      Buffer.data[i][j] = {} -- step
      for k = 1, #new_buffer[i][j] do
        Buffer.data[i][j][k] = new_buffer[i][j][k] -- values
      end
    end
  end  
  
end

function Buffer.print()
  buffer_string = '{'  
  
  for i = 1, #Buffer.data do
    buffer_string = buffer_string .. "{" -- track
    
    for j = 1, #Buffer.data[i] do
      buffer_string = buffer_string .. "{"
      for k = 1, #Buffer.data[i][j] do
        buffer_string = buffer_string .. Buffer.data[i][j][k] .. ','
      end
      buffer_string = buffer_string .. "},"
    end
    
    buffer_string = buffer_string .. "},"
  end
  
  buffer_string = buffer_string .. '}'
  
  return buffer_string
end

return Buffer