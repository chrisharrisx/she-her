local ChordUtil = include('lib/chord_util')

local HarmonyUtil = {}

HarmonyUtil.key = 60
HarmonyUtil.diatonicChords = {
  { 60, 3 }, -- I
  { 62, 4 }, -- ii
  { 64, 5 }, -- iii
  { 65, 6 }, -- IV
  { 67, 7 }, -- V
  { 69, 8 }, -- vi
  { 71, 9 }, -- vii
  { 60, 10 }, -- I maj7
  { 62, 11 }, -- ii min7
  { 64, 12 }, -- iii min7
  { 65, 13 }, -- IV maj7
  { 67, 14 }, -- V dom7
  { 69, 15 }, -- vi min7
  { 71, 16 }, -- vii min7b5
  { 60, 17 }, -- I maj9
  { 65, 18 } -- I maj7#11
}

function HarmonyUtil.getKey()
  return HarmonyUtil.key
end

function HarmonyUtil.setKey(key)
  HarmonyUtil.key = key
end

function HarmonyUtil.getRandDiatonicChordChange(index) 
  choice = math.random(#HarmonyUtil.diatonicChords)
  return HarmonyUtil.diatonicChords[choice]
end

return HarmonyUtil