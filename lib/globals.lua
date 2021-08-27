buffer = include('lib/buffer')
tracks = include('lib/tracks')

sequenceParams, tempoParams, tempo, chance, _key, keyModChance = 1, 1, 1, 1, 1, 1
harmonyParams, chordParams, interval, keyModInterval = 2, 2, 2, 2
keyModParams = 3
keyParams = 4

local Globals = {
  paramSets = {
    {
      title = 'sequence',
      chain = 0,
      chain_position = 1,
      params = {
        { 
          title = 'tempo',
          values = { 60 }
        },
        {

        },
        {
          title = 'reset'
        }
      }
    },
    {
      title = 'harmony',
      follow = 0,
      chord_cycle = 1,
      key_cycle = 1,
      key_mod = false,
      params = {
        {
          title = 'follow track 1',
          values = {
            'off',
            'on'
          }
        },
        {
          title = 'change chord',
          values = {
            0, -- chord randomization chance
            4 -- chord randomization interval (in cycles)
          }
        },
        {
          title = 'change key',
          values = {
            0, -- key randomization amount
            4 -- key randomization interval (in cycles)
          }
        },
        {
          title = 'key',
          values = {
            60 -- key
          }
        }
      }
    },
    {
      title = 'external io',
      
    },
    {
      title = 'save/load',
    },
  }
}

Globals.track_notes = {} -- save note states when follow is enabled

function Globals.get_tempo()
  return Globals.paramSets[sequenceParams].params[tempoParams].values[tempo]
end

function Globals.set_tempo(t)
  Globals.paramSets[sequenceParams].params[tempoParams].values[tempo] = t
  params:set("clock_tempo", t)
end

function Globals.chain()
  -- if Globals.paramSets[sequenceParams].chain == 1 then
  --   return true
  -- end
  -- return false
  return Globals.paramSets[sequenceParams].chain
end

function Globals.get_sequence_mode()
  return Globals.paramSets[sequenceParams].chain
end

function Globals.set_sequence_mode(m)
  Globals.paramSets[sequenceParams].chain = m
end

function Globals.get_chain_position()
  return Globals.paramSets[sequenceParams].chain_position
end

function Globals.set_chain_position(pos)
  Globals.paramSets[sequenceParams].chain_position = pos
end

function Globals.get_follow_state()
  return Globals.paramSets[harmonyParams].follow
end

function Globals.set_follow_state(f)
  Globals.paramSets[harmonyParams].follow = f
end

function Globals.get_chord_chance()
  return Globals.paramSets[harmonyParams].params[chordParams].values[chance]
end

function Globals.set_chord_chance(ch)
  Globals.paramSets[harmonyParams].params[chordParams].values[chance] = ch
end

function Globals.get_chord_interval()
  return Globals.paramSets[harmonyParams].params[chordParams].values[interval]
end

function Globals.set_chord_interval(cf)
  Globals.paramSets[harmonyParams].params[chordParams].values[interval] = cf
end

function Globals.get_chord_cycle()
  return Globals.paramSets[harmonyParams].chord_cycle
end

function Globals.set_chord_cycle(cycle)
  if cycle <= Globals.get_chord_interval() then
    Globals.paramSets[harmonyParams].chord_cycle = cycle
  else
    Globals.paramSets[harmonyParams].chord_cycle = 1
  end
end

function Globals.get_key()
  return Globals.paramSets[harmonyParams].params[keyParams].values[_key]
end

function Globals.set_key(k)
  Globals.paramSets[harmonyParams].params[keyParams].values[_key] = k
end

function Globals.get_keymod_chance()
  return Globals.paramSets[harmonyParams].params[keyModParams].values[keyModChance]
end

function Globals.set_keymod_chance(c)
  Globals.paramSets[harmonyParams].params[keyModParams].values[keyModChance] = c
end

function Globals.get_keymod_interval()
  return Globals.paramSets[harmonyParams].params[keyModParams].values[keyModInterval]
end

function Globals.set_keymod_interval(i)
  Globals.paramSets[harmonyParams].params[keyModParams].values[keyModInterval] = i
end

function Globals.restore_track_notes(state)
  if #Globals.track_notes == 3 then
    for i = 1, #Globals.track_notes do
      tracks[i + 1]:set_root_note(Globals.track_notes[i][1])
      tracks[i + 1]:set_chord(Globals.track_notes[i][2])
    end
  end
end

function Globals.set_track_notes(state)
  for i = 2, #tracks do
    Globals.track_notes[i - 1] = { tracks[i]:get_root_note(), tracks[i]:get_chord() }
  end
end

---------------------------------------------------------------------

Globals.save_slot = 1

function Data(t)
  Globals.set_tempo(t.tempo)
  Globals.set_sequence_mode(t.sequenceMode)
  Globals.set_follow_state(t.follow)
  Globals.set_key(t.key)
  Globals.set_keymod_chance(t.keyModChance)
  Globals.set_keymod_interval(t.keyModInterval)
  Globals.set_chord_interval(t.chordModInterval)
  
  buffer.length = t.bufferLength
  buffer.start = t.bufferStart
  buffer.load_buffer(t.buffer)
  
  tracks[1]:restore_steps(t.track1trigs)
  tracks[1]:apply_rotation(t.track1TrigRotation)
  tracks[1]:set_trig_probability(t.track1TrigChance)
  
  tracks[2]:restore_steps(t.track2trigs)
  tracks[2]:apply_rotation(t.track2TrigRotation)
  tracks[2]:set_trig_probability(t.track2TrigChance)
  
  tracks[3]:restore_steps(t.track3trigs)
  tracks[3]:apply_rotation(t.track3TrigRotation)
  tracks[3]:set_trig_probability(t.track3TrigChance)
  
  tracks[4]:restore_steps(t.track4trigs)
  tracks[4]:apply_rotation(t.track4TrigRotation)
  tracks[4]:set_trig_probability(t.track4TrigChance)
  
end

function Globals.confirm_save(state)
  Globals.savestate(Globals.save_slot, state)
end

function Globals.savestate(slot, state)
  print(buffer.length)
  local file = io.open(_path.data .. 'she/her/song' .. slot .. '.lua', 'w+')
  io.output(file)
  
  io.write('Data{\n')
  io.write('tempo = ', Globals.get_tempo(), ',\n')
  io.write('sequenceMode = ', Globals.get_sequence_mode(), ',\n')
  io.write('follow = ', Globals.get_follow_state(), ',\n')
  io.write('key = ', Globals.get_key(), ',\n')
  io.write('keyModChance = ', Globals.get_keymod_chance(), ',\n')
  io.write('keyModInterval = ', Globals.get_keymod_interval(), ',\n')
  io.write('chordModChance = ', Globals.get_chord_chance(), ',\n')
  io.write('chordModInterval = ', Globals.get_chord_interval(), ',\n')
  io.write('bufferLength = ', buffer.length, ',\n')
  io.write('bufferStart = ', buffer.start, ',\n')
  io.write('buffer = ', buffer.print(), ',\n')
  
  io.write('track1trigs = ', tracks[1]:print_steps(), ',\n')
  io.write('track1TrigRotation = ', tracks[1]:get_rotation(), ',\n')
  io.write('track1TrigChance = ', tracks[1]:get_trig_probability(), ',\n')
  
  io.write('track2trigs = ', tracks[2]:print_steps(), ',\n')
  io.write('track2TrigRotation = ', tracks[2]:get_rotation(), ',\n')
  io.write('track2TrigChance = ', tracks[2]:get_trig_probability(), ',\n')
  
  io.write('track3trigs = ', tracks[3]:print_steps(), ',\n')
  io.write('track3TrigRotation = ', tracks[3]:get_rotation(), ',\n')
  io.write('track3TrigChance = ', tracks[3]:get_trig_probability(), ',\n')
  
  io.write('track4trigs = ', tracks[4]:print_steps(), ',\n')
  io.write('track4TrigRotation = ', tracks[4]:get_rotation(), ',\n')
  io.write('track4TrigChance = ', tracks[4]:get_trig_probability(), ',\n')
  
  io.write('}')

  io.close(file)
end

function Globals.loadstate(slot)
  dofile(_path.data .. 'she/her/song' .. slot .. '.lua')
end

return Globals