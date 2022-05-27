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
  Globals.set_chord_chance(t.chordModChance)
  Globals.set_chord_interval(t.chordModInterval)
  
  tracks[1]:restore_steps(t.track1Trigs)
  tracks[1]:apply_rotation(t.track1TrigRotation)
  tracks[1]:set_trig_probability(t.track1TrigChance)
  tracks[1]:restore_shift_steps(t.track1Shifts)
  tracks[1]:restore_chordshift_steps(t.track1ChordShifts)
  tracks[1]:set_octave_length(t.track1OctaveLength)
  tracks[1]:set_track_shift(t.track1DefaultShift)
  tracks[1]:set_root_note(t.track1Root)
  tracks[1]:set_chord(t.track1Chord)
  tracks[1]:set_play_mode(t.track1PlayMode)
  tracks[1]:set_fixed_velocity(t.track1FixedVelocity)
  tracks[1]:set_max_velocity(t.track1MaxVelocity)
  tracks[1]:set_velocity_randomization(t.track1VelocityChance)
  
  tracks[2]:restore_steps(t.track2Trigs)
  tracks[2]:apply_rotation(t.track2TrigRotation)
  tracks[2]:set_trig_probability(t.track2TrigChance)
  tracks[2]:restore_shift_steps(t.track2Shifts)
  tracks[2]:restore_chordshift_steps(t.track2ChordShifts)
  tracks[2]:set_octave_length(t.track2OctaveLength)
  tracks[2]:set_track_shift(t.track2DefaultShift)
  tracks[2]:set_root_note(t.track2Root)
  tracks[2]:set_chord(t.track2Chord)
  tracks[2]:set_play_mode(t.track2PlayMode)
  tracks[2]:set_fixed_velocity(t.track2FixedVelocity)
  tracks[2]:set_max_velocity(t.track2MaxVelocity)
  tracks[2]:set_velocity_randomization(t.track2VelocityChance)
  
  tracks[3]:restore_steps(t.track3Trigs)
  tracks[3]:apply_rotation(t.track3TrigRotation)
  tracks[3]:set_trig_probability(t.track3TrigChance)
  tracks[3]:restore_shift_steps(t.track3Shifts)
  tracks[3]:restore_chordshift_steps(t.track3ChordShifts)
  tracks[3]:set_octave_length(t.track3OctaveLength)
  tracks[3]:set_track_shift(t.track3DefaultShift)
  tracks[3]:set_root_note(t.track3Root)
  tracks[3]:set_chord(t.track3Chord)
  tracks[3]:set_play_mode(t.track3PlayMode)
  tracks[3]:set_fixed_velocity(t.track3FixedVelocity)
  tracks[3]:set_max_velocity(t.track3MaxVelocity)
  tracks[3]:set_velocity_randomization(t.track3VelocityChance)
  
  tracks[4]:restore_steps(t.track4Trigs)
  tracks[4]:apply_rotation(t.track4TrigRotation)
  tracks[4]:set_trig_probability(t.track4TrigChance)
  tracks[4]:restore_shift_steps(t.track4Shifts)
  tracks[4]:restore_chordshift_steps(t.track4ChordShifts)
  tracks[4]:set_octave_length(t.track4OctaveLength)
  tracks[4]:set_track_shift(t.track4DefaultShift)
  tracks[4]:set_root_note(t.track4Root)
  tracks[4]:set_chord(t.track4Chord)
  tracks[4]:set_play_mode(t.track4PlayMode)
  tracks[4]:set_fixed_velocity(t.track4FixedVelocity)
  tracks[4]:set_max_velocity(t.track4MaxVelocity)
  tracks[4]:set_velocity_randomization(t.track4VelocityChance)
  
end

function Globals.confirm_save(state)
  Globals.savestate(Globals.save_slot, state)
end

function Globals.savestate(slot, state)
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
  
  io.write('track1Trigs = ', tracks[1]:print_steps(), ',\n')
  io.write('track1TrigRotation = ', tracks[1]:get_rotation(), ',\n')
  io.write('track1TrigChance = ', tracks[1]:get_trig_probability(), ',\n')
  io.write('track1Shifts = ', tracks[1]:print_shift_steps(), ',\n')
  io.write('track1ChordShifts = ', tracks[1]:print_chordshift_steps(), ',\n')
  io.write('track1OctaveLength = ', tracks[1]:get_octave_length(), ',\n')
  io.write('track1DefaultShift = ', tracks[1]:get_track_shift(), ',\n')
  io.write('track1Root = ', tracks[1]:get_root_note(), ',\n')
  io.write('track1Chord = ', tracks[1]:get_chord(), ',\n')
  io.write('track1PlayMode = ', tracks[1]:get_play_mode(), ',\n')
  io.write('track1FixedVelocity = ', tracks[1]:get_fixed_velocity(), ',\n')
  io.write('track1MaxVelocity = ', tracks[1]:get_max_velocity(), ',\n')
  io.write('track1VelocityChance = ', tracks[1]:get_velocity_randomization(), ',\n')
  
  io.write('track2Trigs = ', tracks[2]:print_steps(), ',\n')
  io.write('track2TrigRotation = ', tracks[2]:get_rotation(), ',\n')
  io.write('track2TrigChance = ', tracks[2]:get_trig_probability(), ',\n')
  io.write('track2Shifts = ', tracks[2]:print_shift_steps(), ',\n')
  io.write('track2ChordShifts = ', tracks[2]:print_chordshift_steps(), ',\n')
  io.write('track2OctaveLength = ', tracks[2]:get_octave_length(), ',\n')
  io.write('track2DefaultShift = ', tracks[2]:get_track_shift(), ',\n')
  io.write('track2Root = ', tracks[2]:get_root_note(), ',\n')
  io.write('track2Chord = ', tracks[2]:get_chord(), ',\n')
  io.write('track2PlayMode = ', tracks[2]:get_play_mode(), ',\n')
  io.write('track2FixedVelocity = ', tracks[2]:get_fixed_velocity(), ',\n')
  io.write('track2MaxVelocity = ', tracks[2]:get_max_velocity(), ',\n')
  io.write('track2VelocityChance = ', tracks[2]:get_velocity_randomization(), ',\n')
  
  io.write('track3Trigs = ', tracks[3]:print_steps(), ',\n')
  io.write('track3TrigRotation = ', tracks[3]:get_rotation(), ',\n')
  io.write('track3TrigChance = ', tracks[3]:get_trig_probability(), ',\n')
  io.write('track3Shifts = ', tracks[3]:print_shift_steps(), ',\n')
  io.write('track3ChordShifts = ', tracks[3]:print_chordshift_steps(), ',\n')
  io.write('track3OctaveLength = ', tracks[3]:get_octave_length(), ',\n')
  io.write('track3DefaultShift = ', tracks[3]:get_track_shift(), ',\n')
  io.write('track3Root = ', tracks[3]:get_root_note(), ',\n')
  io.write('track3Chord = ', tracks[3]:get_chord(), ',\n')
  io.write('track3PlayMode = ', tracks[3]:get_play_mode(), ',\n')
  io.write('track3FixedVelocity = ', tracks[3]:get_fixed_velocity(), ',\n')
  io.write('track3MaxVelocity = ', tracks[3]:get_max_velocity(), ',\n')
  io.write('track3VelocityChance = ', tracks[3]:get_velocity_randomization(), ',\n')
  
  io.write('track4Trigs = ', tracks[4]:print_steps(), ',\n')
  io.write('track4TrigRotation = ', tracks[4]:get_rotation(), ',\n')
  io.write('track4TrigChance = ', tracks[4]:get_trig_probability(), ',\n')
  io.write('track4Shifts = ', tracks[4]:print_shift_steps(), ',\n')
  io.write('track4ChordShifts = ', tracks[4]:print_chordshift_steps(), ',\n')
  io.write('track4OctaveLength = ', tracks[4]:get_octave_length(), ',\n')
  io.write('track4DefaultShift = ', tracks[4]:get_track_shift(), ',\n')
  io.write('track4Root = ', tracks[4]:get_root_note(), ',\n')
  io.write('track4Chord = ', tracks[4]:get_chord(), ',\n')
  io.write('track4PlayMode = ', tracks[4]:get_play_mode(), ',\n')
  io.write('track4FixedVelocity = ', tracks[4]:get_fixed_velocity(), ',\n')
  io.write('track4MaxVelocity = ', tracks[4]:get_max_velocity(), ',\n')
  io.write('track4VelocityChance = ', tracks[4]:get_velocity_randomization(), ',\n')
  
  io.write('}')

  io.close(file)
end

function Globals.loadstate(slot)
  dofile(_path.data .. 'she/her/song' .. slot .. '.lua')
end

return Globals