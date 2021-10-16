local note = 1
local velocity = 2
local track = 3

local Buffer = {}

Buffer.data = {
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
  },
  {
    {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {},
  }
}

Buffer.slots = {
  {},
  {},
  {},
  {}
}
Buffer.slot_lengths = { 16, 16, 16, 16 }
Buffer.active_slot = 1
Buffer.next_slot = 1
Buffer.loop_slot_dirty = 0

Buffer.loop = 0
Buffer.loop_next = 0
Buffer.loop_state_dirty = 0

Buffer.length = 16
Buffer.length_changed = 0
Buffer.start = 1
Buffer.start_changed = 0

Buffer.read_write_positions = { 1, 1, 1, 1 }

function Buffer.write_slot_data()
  Buffer.slots[Buffer.active_slot] = {}
  for i = 1, #Buffer.data do
    Buffer.slots[Buffer.active_slot][i] = {}
    for j = 1, #Buffer.data[i] do
      Buffer.slots[Buffer.active_slot][i][j] = {}
      for k = 1, #Buffer.data[i][j] do
        Buffer.slots[Buffer.active_slot][i][j][k] = Buffer.data[i][j][k]
      end
    end
  end
end

function Buffer.empty_slot()
  Buffer.slots[Buffer.active_slot] = {}
end

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
  -- return Buffer.data[track][Buffer.read_write_positions[track] + Buffer.start - 1]
  if #Buffer.slots[Buffer.active_slot] == 0 then
    return Buffer.data[track][Buffer.read_write_positions[track] + Buffer.start - 1]
  else
    return Buffer.slots[Buffer.active_slot][track][Buffer.read_write_positions[track] + Buffer.start - 1]
  end
end

function Buffer.advance(track, state)
    length = Buffer.loop == 1 and Buffer.slot_lengths[buffer.active_slot] or Buffer.length

    if Buffer.read_write_positions[track] < length then
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

function Buffer.load_slot(slot_num, slot_length, slot_data)
  Buffer.slots[slot_num] = nil 
  Buffer.slots[slot_num] = {}
  Buffer.slot_lengths[slot_num] = slot_length
  
  for i = 1, #slot_data do
    Buffer.slots[slot_num][i] = {}
    
    for j = 1, #slot_data[i] do
      Buffer.slots[slot_num][i][j] = slot_data[i][j]
    end
  end
end

function Buffer.print(slot_num)
  buffer_string = '{'  
  
  for i = 1, #Buffer.slots[slot_num] do
    buffer_string = buffer_string .. "{" -- track
    
    for j = 1, #Buffer.slots[slot_num][i] do
      buffer_string = buffer_string .. "{"
      for k = 1, #Buffer.slots[slot_num][i][j] do
        buffer_string = buffer_string .. Buffer.slots[slot_num][i][j][k] .. ','
      end
      buffer_string = buffer_string .. "},"
    end
    
    buffer_string = buffer_string .. "},"
  end
  
  buffer_string = buffer_string .. '}'
  
  return buffer_string
end

function Buffer.print_to_console(slot_num)
  print(Buffer.print(slot_num))
end

return Buffer