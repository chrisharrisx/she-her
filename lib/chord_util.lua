local ChordUtil = {}

ChordUtil.notes = {
  'C-2', 'C#-2', 'D-2', 'D#-2', 'E-2', 'F-2', 'F#-2', 'G-2', 'G#-2', 'A-2', 'A#-2', 'B-2',  -- 0 - 11
  'C-1', 'C#-1', 'D-1', 'D#-1', 'E-1', 'F-1', 'F#-1', 'G-1', 'G#-1', 'A-1', 'A#-1', 'B-1',  -- 12 - 23
  'C0', 'C#0', 'D0', 'D#0', 'E0', 'F0', 'F#0', 'G0', 'G#0', 'A0', 'A#0', 'B0',              -- 24 - 35
  'C1', 'C#1', 'D1', 'D#1', 'E1', 'F1', 'F#1', 'G1', 'G#1', 'A1', 'A#1', 'B1',              -- 36 - 47
  'C2', 'C#2', 'D2', 'D#2', 'E2', 'F2', 'F#2', 'G2', 'G#2', 'A2', 'A#2', 'B2',              -- 48 - 59
  'C3', 'C#3', 'D3', 'D#3', 'E3', 'F3', 'F#3', 'G3', 'G#3', 'A3', 'A#3', 'B3',              -- 60 - 71
  'C4', 'C#4', 'D4', 'D#4', 'E4', 'F4', 'F#4', 'G4', 'G#4', 'A4', 'A#4', 'B4',              -- 72 - 83
  'C5', 'C#5', 'D5', 'D#5', 'E5', 'F5', 'F#5', 'G5', 'G#5', 'A5', 'A#5', 'B5',              -- 84 - 95
  'C6', 'C#6', 'D6', 'D#6', 'E6', 'F6', 'F#6', 'G6', 'G#6', 'A6', 'A#6', 'B6',              -- 96 - 107
  'C7', 'C#7', 'D7', 'D#7', 'E7', 'F7', 'F#7', 'G7', 'G#7', 'A7', 'A#7', 'B7',              -- 108 - 119
  'C8', 'C#8', 'D8', 'D#8', 'E8', 'F8', 'F#8', 'G8'                                         -- 120 - 127
}

ChordUtil.scales = {
  ionian = { -24, -22, -20, -19, -17, -15, -13, -12, -10, -8, -7, -5, -3, -1, 
    0, 2, 4, 5, 7, 9, 11, 12, 14, 16, 17, 19, 21, 23, 24, 26, 28, 29, 31, 33, 35
  },
  dorian = { -24, -22, -21, -19, -17, -15, -14, -12, -10, -9, -7, -5, -3, -2, 
    0, 2, 3, 5, 7, 9, 10, 12, 14, 15, 17, 19, 21, 22, 24, 26, 27, 29, 31, 33, 34
  },
  phrygian = { -24, -23, -21, -19, -17, -16, -14, -12, -11, -9, -7, -5, -4, -2,
    0, 1, 3, 5, 7, 8, 10, 12, 13, 15, 17, 19, 20, 22, 24, 25, 27, 29, 31, 32, 34 
  },
  lydian = { -24, -22, -20, -18, -17, -15, -13, -12, -10, -8, -6, -5, -3, -1,
    0, 2, 4, 6, 7, 9, 11, 12, 14, 16, 18, 19, 21, 23, 24, 26, 28, 30, 31, 35
  },
  mixolydian = { -24, -22, -20, -19, -17, -15, -14, -12, -10, -8, -7, -5, -3, -2,
    0, 2, 4, 5, 7, 9, 10, 12, 14, 16, 17, 19, 21, 22, 24, 26, 28, 29, 31, 33, 34 
  },
  aeolian = { -24, -22, -21, -19, -17, -16, -14, -12, -10, -9, -7, -5, -4, -2,
    0, 2, 3, 5, 7, 8, 10, 12, 14, 15, 17, 19, 20, 22, 24, 26, 27, 29, 31, 32, 34
  },
  locrian = { -24, -23, -21, -19, -18, -16, -14, -12, -11, -9, -7, -6, -4, -2,
    0, 1, 3, 5, 6, 8, 10, 12, 13, 15, 17, 18, 20, 22, 24, 25, 27, 29, 30, 32, 34
  }
}

ChordUtil.chords = {
  { name = 'fixed', value = { 0 } },
  { name = 'root', value = { 0 }, scale = ChordUtil.scales.ionian },
  
  -- diatonic triads
  { name = 'I', value = { 0, 4, 7 }, scale = ChordUtil.scales.ionian },
  { name = 'ii', value = { 0, 3, 7 }, scale = ChordUtil.scales.dorian },
  { name = 'iii', value = { 0, 3, 7 }, scale = ChordUtil.scales.phrygian },
  { name = 'IV', value = { 0, 4, 7 }, scale = ChordUtil.scales.lydian },
  { name = 'V', value = { 0, 4, 7 }, scale = ChordUtil.scales.mixolydian },
  { name = 'vi', value = { 0, 3, 7 }, scale = ChordUtil.scales.aeolian },
  { name = 'vii', value = { 0, 3, 6 }, scale = ChordUtil.scales.locrian },
  
  -- diatonic seventh chords
  { name = 'I7', value = { 0, 4, 7, 11 }, scale = ChordUtil.scales.ionian },
  { name = 'ii7', value = { 0, 3, 7, 10 }, scale = ChordUtil.scales.dorian },
  { name = 'iii7', value = { 0, 3, 7, 10 }, scale = ChordUtil.scales.phrygian },
  { name = 'IV7', value = { 0, 4, 7, 11 }, scale = ChordUtil.scales.lydian },
  { name = 'V7', value = { 0, 4, 7, 10 }, scale = ChordUtil.scales.mixolydian },
  { name = 'vi7', value = { 0, 3, 7, 10 }, scale = ChordUtil.scales.aeolian },
  { name = 'vii7', value = { 0, 3, 6, 10 }, scale = ChordUtil.scales.locrian },
  
  -- extended chords
  { name = 'I9', value = { 0, 4, 7, 11, 14 }, scale = ChordUtil.scales.ionian },
  { name = 'IV9#11', value = { 0, 4, 7, 11, 18 }, scale = ChordUtil.scales.lydian },
  
  -- other triads
  { name = 'aug', value = { 0, 4, 8 }, scale = ChordUtil.scales.lydian },
  { name = 'sus', value = { 0, 5, 7 }, scale = ChordUtil.scales.ionian },
  
  -- 🍌
  { name = 'quart', value = { 0, 5, 10, 15 }, scale = ChordUtil.scales.ionian }, -- ADD QUART MAJ AND QUART MIN
  { name = 'quint', value = { 0, 7, 14, 21 }, scale = ChordUtil.scales.ionian }
}


ChordUtil.modulations = {
  { -- I chord
    {-5, 6}, -- common chord modulation, I chord --> IV chord of new key
    {-2, 4}, -- {new key, new chord} -- modulate down whole step, I chord --> ii of new key
  },
  {}, -- ii chord
  {}, -- iii chord
  {}, -- IV chord
  {}, -- V chord
  {}, -- vi chord
  {} -- vii chord
}

ChordUtil.playMode = {
  'arpU',
  'arpD',
  'arpR',
  'chord'
}

ChordUtil.shifts = {
  'm2',
  'M2',
  'm3',
  'M3',
  'P4',
  '#4',
  'P5',
  'm6',
  'M6',
  'm7',
  'M7',
  '8va'
}

ChordUtil.chord_shifts = {
  '2nd',
  '3rd',
  '4th',
  '5th',
  '6th',
  '7th',
  '8va'
}

ChordUtil.inversion = {
  'dr3',
  'dr2',
  'root',
  '1st',
  '2nd'
}

function ChordUtil.getNoteNameForNumber(number)
  return ChordUtil.notes[number + 1]
end

function ChordUtil.getChordNameForNumber(number)
  return ChordUtil.chords[number].name
end

function ChordUtil.getScaleForChord(chord)
  return ChordUtil.chords[chord].scale
end

function ChordUtil.getOffsetsForChord(chord)
  return ChordUtil.chords[chord].value
end

function ChordUtil.getInversionForChord(chord, inv)
  -- raise third an octave for drop 2 and drop 3
  if inv < 0 and chord[2] + 12 <= 127 then
    third = chord[2]
    table.remove(chord, 2)
    table.insert(chord, third + 12)
  end
  
  -- raise fifth an octave for drop 3
  if inv == -2 and chord[2] + 12 <= 127 then
    fifth = chord[2]
    table.remove(chord, 2)
    table.insert(chord, fifth + 12)
  end
  
  -- first inversion
  if inv > 0 and chord[1] + 12 <= 127 then
    root = chord[1]
    table.remove(chord, 1)
    table.insert(chord, root + 12)
  end
  
  -- second inversion
  if inv == 2 and chord[1] + 12 <= 127 then
    third = chord[1]
    table.remove(chord, 1)
    table.insert(chord, third + 12)
  end
  
  return chord
end

function ChordUtil.getNotesforOffsets(offsets)
  notes = {}
  for i = 1, #offsets do
    table.insert(notes, r + offsets[i]) -- TODO = calculate inversion
  end
  return notes
end

function ChordUtil.getOctaveOfRoot(root)
  if root == 0 then return 1 end
  if root > 0 then
    return math.floor(root/12) + 1
  end
end

function ChordUtil.getRootForOctave(root, octave)
  current_octave = ChordUtil.getOctaveOfRoot(root)
  octave_diff = current_octave + octave
  return root + (12 * octave_diff)
end

return ChordUtil