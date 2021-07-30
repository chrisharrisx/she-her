sequenceParams, tempoParams, tempo, chance = 1, 1, 1, 1
harmonyParams, chordParams, interval = 2, 2, 2

local Globals = {
  paramSets = {
    {
      title = 'sequence',
      chain = true,
      chain_position = 1,
      params = {
        { 
          title = 'tempo',
          values = { 120 }
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
        }
      }
    },
    {
      title = 'loop',
    },
    {
      title = 'external io',
      
    }
  }
}

function Globals.get_tempo()
  return Globals.paramSets[sequenceParams].params[tempoParams].values[tempo]
end

function Globals.set_tempo(t)
  Globals.paramSets[sequenceParams].params[tempoParams].values[tempo] = t
  params:set("clock_tempo", t)
end

function Globals.chain()
  return Globals.paramSets[sequenceParams].chain
end

function Globals.set_chain()
  Globals.paramSets[sequenceParams].chain = not Globals.paramSets[sequenceParams].chain
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

return Globals