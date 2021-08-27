buffer = include('lib/buffer')
tracks = include('lib/tracks')

local er = require 'er'

local ChordUtil = include('lib/chord_util')
local HarmonyUtil = include('lib/harmony_util')
local MusicUtil = require('musicutil')

--   state.tempo = util.clamp(state.global.tempo + d, 30, 300)
--   params:set('clock_tempo', state.global.tempo)

function set_loop_state(state, d)
  clock.sync(1)
  buffer.loop = util.clamp(buffer.loop + d, 0, 1)
  buffer.print()
  clock.cancel(state.sync)
  state.sync = 0
end

function set_loop_length(state, d)
  buffer.length = util.clamp(buffer.length + d, 1, 64)
end

function set_loop_start(state, d)
  buffer.start = util.clamp(buffer.start + d, 1, 64 - buffer.length)
  buffer.start_changed = 1
end

local enc_actions = {
  {-- VIEW 1 - her - track selection
    {-- encoder = 1
      
    }, 
    {-- encoder = 2 
      {-- paramSet = 1 
        function(state, d) -- param = 1
          state.active_track = util.clamp(state.active_track + d, 1, #tracks)
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
          active_track = tracks[state.active_track]
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
          active_track = tracks[state.active_track]
          div = active_track:get_division()
          active_track:set_division(util.clamp(div + d, 1, #active_track.divisions))
        end,
        function(state, d) -- set trig probability
          active_track = tracks[state.active_track]
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
          if active_track:get_chord() > 2 then
            track_shift = util.clamp(track_shift + d, 2, 8)
          else
            track_shift = util.clamp(track_shift + d, 2, 13)
          end
          active_track:set_track_shift(track_shift)
        end
      },
      {-- notes
        function(state, d) end,
        function(state, d) -- edit root note
          active_track = tracks[state.active_track]
          rootNote = active_track:get_root_note()
          active_track:set_root_note(util.clamp(rootNote + d, 0, 127))
        end,
        function(state, d) -- edit chord
          active_track = tracks[state.active_track]
          ch = active_track:get_chord()
          new_ch = util.clamp(ch + d, 1, #ChordUtil.chords)
          active_track:set_chord(new_ch)
          if state.active_track == 1 then
            state.track_1_chord = new_ch
          end
        end,
        function(state, d) -- edit chord type
          active_track = tracks[state.active_track]
          ct = active_track:get_play_mode()
          active_track:set_play_mode(util.clamp(ct + d, 1, #ChordUtil.playMode))
        end
      },
      {-- velocity
        function(state, d) end,
        function(state, d) -- edit fixed velocity
          active_track = tracks[state.active_track]
          fv = active_track:get_fixed_velocity()
          active_track:set_fixed_velocity(util.clamp(fv + d, 0, 127))
        end,
        function(state, d) -- edit max velocity
          active_track = tracks[state.active_track]
          mv = active_track:get_max_velocity()
          active_track:set_max_velocity(util.clamp(mv + d, 0, 127))
        end,
        function(state, d) -- edit velocity randomization
          active_track = tracks[state.active_track]
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
            active_track = tracks[state.active_track]
            numSteps = active_track:get_length()
            if numSteps + d <= 16 and numSteps + d > 0 then
              active_track:set_steps(er.gen(active_track:get_pulses(), numSteps + d, 0))
            end
          else -- set step length for all tracks simultaneously
            for i = 1, #tracks do
              active_track = tracks[i]
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
            active_track = tracks[state.active_track]
            degree = active_track:get_shift_step_degree(state.active_octave_step)
            if active_track:get_chord() > 2 then
              active_track:set_shift_step_degree(state.active_octave_step, util.clamp(degree + d, 2, 8))
            else
              active_track:set_shift_step_degree(state.active_octave_step, util.clamp(degree + d, 2, 13)) ------------------------------------------------------
            end
          end
        end,
        function(state, d)
          active_track:set_octave_steps(state, d)
        end
      },
      {-- notes
        function(state, d) end,
        function(state, d)
          active_track = tracks[state.active_track]
          root = active_track:get_root_note()
          if d > 0 then
            tracks[state.active_track]:set_root_note(root + 12)
          else
            tracks[state.active_track]:set_root_note(root - 12)
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
      {-- tempo
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
        function(state, d) end,
        function(state, d)
          m = state.globals.get_sequence_mode()
          m = util.clamp(m + d, 0, 1)
          state.globals.set_sequence_mode(m)
        end
      }
    }
  },
  {-- VIEW 5 - she - global harmony edit
    {-- encoder = 1
      
    },
    {-- encoder = 2
      {-- paramSet = 1
        function(state, d) -- choose paramSet
          state.paramSet = util.clamp(state.paramSet + d, 1, #state.globals.paramSets[harmonyParams].params)
        end,
        function(state, d)
          follow = state.globals.get_follow_state()
          follow = util.clamp(follow + d, 0, 1)
          
          if follow == 1 then
            state.globals.set_track_notes(state)
          end
          if follow == 0 then
            print('found table with length 4')
            state.globals.restore_track_notes(state)
          end
          
          state.globals.set_follow_state(follow)
        end
      },
      {-- paramSet = 2    set key
        function(state, d) end,
        function(state, d)
          k = state.globals.get_key()
          k = util.clamp(k + d, 60, 71)
          state.globals.set_key(k)
        end
      },
      {-- paramSet = 3    key modulation
        
      },
      {-- paramSet = 4    chord modulation
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
  },
  {-- VIEW 6 - she - external io edit
    
  },
  {-- VIEW 7 - she - save/load edit
    {-- encoder 1
      
    },
    {-- encoder 2
      {-- paramSet 1 - save
        function(state, d) end,
        function(state, d)
          s = state.globals.save_slot
          s = util.clamp(s + d, 1, 8)
          state.globals.save_slot = s
        end
      }
    }
  }
}

function do_enc_action(state, n, d)
  if n == 1 then
    if state.alt == 0 and state.sync == 0 then
      state.sync = clock.run(set_loop_state, state, d)
    elseif state.alt == 1 and state.key == 1 then
      set_loop_length(state, d)
    elseif state.alt == 1 and state.key == 2 then
      set_loop_start(state, d)
    end
  else
    handler = state.active_paramSet == 2 and 1 or state.active_param
    enc_actions[state.view][n][state.active_paramSet][state.active_param](state, d)
  end
end

return do_enc_action