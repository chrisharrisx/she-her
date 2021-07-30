local er = require 'er'

local ChordUtil = include('lib/chord_util')

--   state.tempo = util.clamp(state.global.tempo + d, 30, 300)
--   params:set('clock_tempo', state.global.tempo)

function set_loop_state(state, d)
  clock.sync(1)
  state.buffer.loop = util.clamp(state.buffer.loop + d, 0, 1)
  clock.cancel(state.sync)
  state.sync = 0
end

function set_loop_length(state, d)
  state.buffer.length = util.clamp(state.buffer.length + d, 1, 64)
end

local enc_actions = {
  {-- VIEW 1 - her - track selection
    {-- encoder = 1
      
    }, 
    {-- encoder = 2 
      {-- paramSet = 1 
        function(state, d) -- param = 1
          state.active_track = util.clamp(state.active_track + d, 1, #state.tracks)
        end
      }
    }
  },
  { -- VIEW 2 - her - track edit
    {-- encoder = 1
      
    }, 
    {-- encoder = 2 
      {-- steps
        function(state, d) -- choose paramSet
          state.paramSet = util.clamp(state.paramSet + d, 1, #active_track.paramSets)
        end,
        function(state, d) -- set pulses
          active_track = state.tracks[state.active_track]
          numSteps = active_track:get_length()
          numPulses = active_track:get_pulses()
          
          if state.alt == 0 then
            if numPulses + d >= 0 and numPulses + d <= 16 then
              active_track:set_pulses(numPulses + d)
              active_track:set_steps(er.gen(numPulses + d, numSteps, 0))
            end
          else
            rotation = active_track:get_rotation()
            active_track:set_rotation(util.clamp(rotation + d, 0, numSteps))
            active_track:set_steps(er.gen(numPulses, numSteps, active_track:get_rotation()))
          end
        end,
        function(state, d) -- set division
          active_track = state.tracks[state.active_track]
          div = active_track:get_division()
          active_track:set_division(util.clamp(div + d, 1, #active_track.divisions))
        end,
        function(state, d) -- set trig probability
          active_track = state.tracks[state.active_track]
          prob = active_track:get_trig_probability()
          active_track:set_trig_probability(util.clamp(prob + d, 0, 100))
        end
      },
      {-- shift
        function(state, d) end,
        function(state, d)
          if state.alt == 0 then -- set shift step
            state.active_octave_step = util.clamp(state.active_octave_step + d, 1, active_track:get_octave_length())
          else -- set shift multiple
            o_step = active_track:get_octave_step(state.active_octave_step)
            o_step = util.clamp(o_step + d, -2, 2)
            active_track:set_shift_step_multiple(state.active_octave_step, o_step)
          end
        end,
        function(state, d) -- set shift degree for all shift steps
          track_shift = active_track:get_track_shift()
          track_shift = util.clamp(track_shift + d, 2, 8)
          active_track:set_track_shift(track_shift)
        end
      },
      {-- notes
        function(state, d) end,
        function(state, d) -- edit root note
          active_track = state.tracks[state.active_track]
          rootNote = active_track:get_root_note()
          active_track:set_root_note(util.clamp(rootNote + d, 0, 127))
        end,
        function(state, d) -- edit chord
          active_track = state.tracks[state.active_track]
          ch = active_track:get_chord()
          active_track:set_chord(util.clamp(ch + d, 1, #ChordUtil.chords))
        end,
        function(state, d) -- edit chord type
          active_track = state.tracks[state.active_track]
          ct = active_track:get_play_mode()
          active_track:set_play_mode(util.clamp(ct + d, 1, #ChordUtil.playMode))
        end
      },
      {-- velocity
        function(state, d) end,
        function(state, d) -- edit fixed velocity
          active_track = state.tracks[state.active_track]
          fv = active_track:get_fixed_velocity()
          active_track:set_fixed_velocity(util.clamp(fv + d, 0, 127))
        end,
        function(state, d) -- edit max velocity
          active_track = state.tracks[state.active_track]
          mv = active_track:get_max_velocity()
          active_track:set_max_velocity(util.clamp(mv + d, 0, 127))
        end,
        function(state, d) -- edit velocity randomization
          active_track = state.tracks[state.active_track]
          vr = active_track:get_velocity_randomization()
          active_track:set_velocity_randomization(util.clamp(vr + d, 0, 100))
        end
      }
    },
    {-- encoder = 3
      {-- steps
        function(state, d) end,
        function(state, d) -- set step length
          if state.alt == 0 then -- set step length for active track only
            active_track = state.tracks[state.active_track]
            numSteps = active_track:get_length()
            if numSteps + d <= 16 and numSteps + d > 0 then
              active_track:set_steps(er.gen(active_track:get_pulses(), numSteps + d, 0))
            end
          else -- set step length for all tracks simultaneously
            for i = 1, #state.tracks do
              active_track = state.tracks[i]
              numSteps = active_track:get_length()
              if numSteps + d <= 16 and numSteps + d > 0 then
                active_track:set_steps(er.gen(active_track:get_pulses(), numSteps + d, 0))
              end
            end
          end
          
        end
      },
      {-- shift
        function(state, d) end,
        function(state, d)
          length = active_track:get_octave_length()
          length = util.clamp(length + d, 1, 16)
          if state.alt == 0 then
            active_track:set_octave_length(length)
            if state.active_octave_step > active_track:get_octave_length() then
              state.active_octave_step = active_track:get_octave_length()
            end
          else
            active_track = state.tracks[state.active_track]
            degree = active_track:get_shift_step_degree(state.active_octave_step)
            active_track:set_shift_step_degree(state.active_octave_step, util.clamp(degree + d, 2, 8))
          end
        end,
        function(state, d)
          active_track:set_octave_steps(state, d)
        end
      },
      {-- notes
        function(state, d) end,
        function(state, d)
          active_track = state.tracks[state.active_track]
          root = active_track:get_root_note()
          if d > 0 then
            state.tracks[state.active_track]:set_root_note(root + 12)
          else
            state.tracks[state.active_track]:set_root_note(root - 12)
          end
        end
      }
    }
  },
  {-- VIEW 3 - she - global setting selection
    {-- encoder = 1
      
    }, 
    {-- encoder = 2
      {-- paramSet = 1 
        function(state, d) -- param = 1
          state.active_global = util.clamp(state.active_global + d, 1, #state.globals.paramSets)
        end
      }
    }
  },
  {-- VIEW 4 - she - global sequence edit
    {-- encoder = 1
      
    },
    {-- encoder = 2
      {-- paramSet = 1
        function(state, d) -- choose paramSet
          state.paramSet = util.clamp(state.paramSet + d, 1, #state.globals.paramSets[sequenceParams].params)
        end,
        function(state, d)
          t = state.globals.get_tempo()
          t = util.clamp(t + d, 30, 300)
          state.globals.set_tempo(t)
        end
      },
      {-- paramSet = 2
        
      }
    }
  },
  {-- VIEW 5 - she - global harmony edit
    {-- encoder = 1
      
    },
    {-- encoder = 2
      {-- paramSet = 1
        function(state, d) -- choose paramSet
          state.paramSet = util.clamp(state.paramSet + d, 1, #state.globals.paramSets[sequenceParams].params)
        end,
        function(state, d)
          follow = state.globals.get_follow_state()
          follow = util.clamp(follow + d, 0, 1)
          state.globals.set_follow_state(follow)
        end
      },
      {-- paramSet = 2
        function(state, d) end,
        function(state, d)
          c = state.globals.get_chord_chance()
          c = util.clamp(c + d, 0, 100)
          state.globals.set_chord_chance(c)
        end,
        function(state, d)
          f = state.globals.get_chord_interval()
          f = util.clamp(f + d, 0, 64)
          state.globals.set_chord_interval(f)
        end
      }
    }
  }
}

function do_enc_action(state, n, d)
  if n == 1 then
    if state.alt == 0 and state.sync == 0 then
      state.sync = clock.run(set_loop_state, state, d)
    elseif state.alt == 1 then
      set_loop_length(state, d)
    end
  else
    handler = state.active_paramSet == 2 and 1 or state.active_param
    enc_actions[state.view][n][state.active_paramSet][state.active_param](state, d)
  end
end

return do_enc_action