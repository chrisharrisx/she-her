local ChordUtil = include('lib/chord_util')

local HarmonyUtil = {}

HarmonyUtil.diatonicChords = {
  { 0, 3 }, -- I
  { 2, 4 }, -- ii
  { 4, 5 }, -- iii
  { 5, 6 }, -- IV
  { 7, 7 }, -- V
  { 9, 8 }, -- vi
  { 11, 9 }, -- vii
  { 0, 10 }, -- I maj7
  { 2, 11 }, -- ii min7
  { 4, 12 }, -- iii min7
  { 5, 13 }, -- IV maj7
  { 7, 14 }, -- V dom7
  { 9, 15 }, -- vi min7
  { 11, 16 }, -- vii min7b5
  { 0, 17 }, -- I maj9
  { 5, 18 } -- I maj7#11
}

function HarmonyUtil.getRandDiatonicChordChange(state) 
  choice = math.random(#HarmonyUtil.diatonicChords)
  new_chord = HarmonyUtil.diatonicChords[choice]
  return { state.globals.get_key() + new_chord[1], new_chord[2] }
end

return HarmonyUtil