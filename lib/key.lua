local key_actions = {
  {-- VIEW 1 - her - track selection
    {-- key = 1
    }, 
    {-- key = 2
      function(state)
        state.view = 3
        state.key = 0
      end
    },
    {-- key = 3
      function(state)
        state.view = 2
        state.paramSet = 1
        state.key = 0
      end
    }
  },
  {-- VIEW 2 - her - track edit
    {-- key = 1
    }, 
    {-- key = 2
      function(state)
        state.view = 1
        state.key = 0
      end,
      function(state)
        if state.active_param > 1 then
          state.active_param = state.active_param - 1
          if state.active_param == 2 and state.paramSet == 2 then
            state.active_octave_step = 1
          end
          if state.active_param == 1 then
            state.active_paramSet = 1
            state.active_octave_step = 0
          end
        end
        state.key = 0
      end
    },
    {-- key = 3
      function(state)
        state.active_paramSet = state.paramSet
        state.active_param = 2
        if state.active_paramSet == 2 then
          state.active_octave_step = 1
        end
        state.key = 0
      end,
      function(state)
        active_track = state.tracks[state.active_track]
        if state.active_param <= #active_track.paramSets[state.active_paramSet].values then -- move through params in set
          state.active_param = state.active_param + 1
        end
        if state.active_paramSet == 2 then
          state.active_octave_step = 0
        end
        state.key = 0
      end
    }
  },
  {-- VIEW 3 - she - settings selection
    {-- key = 1
      
    },
    {-- key = 2
      function(state)
        state.view = 1
        state.key = 0
      end
    },
    {-- key = 3
      function(state)
        state.paramSet = 1
        state.view = 3 + state.active_global
      end
    }
  },
  {-- VIEW 4 - she - edit global sequence settings
    {-- key = 1
      
    },
    {-- key = 2
      function(state)
        state.view = 3
        state.key = 0
      end,
      function(state)
        if state.active_param > 1 then
          state.active_param = state.active_param - 1
        end
        if state.active_param == 1 then
          state.active_paramSet = 1
        end
        state.key = 0
      end
    },
    {-- key = 3
      function(state)
        state.active_paramSet = state.paramSet
        state.active_param = 2
        state.key = 0
      end,
      function(state)
        if state.paramSet ~= 2 then
          state.active_paramSet = 1
          state.active_param = 2
        else
          state.reset = clock.run(state.tracks.reset, state.reset)
        end
        state.key = 0
      end
    },
  },
  {-- VIEW 5 - she - edit global harmony settings
    {-- key = 1
      
    },
    {-- key = 2
      function(state)
        state.view = 3
        state.key = 0
      end,
      function(state)
        state.active_param = state.active_param - 1
        if state.active_param == 1 then
          state.active_paramSet = 1
        else
          state.active_paramSet = state.paramSet
        end
        state.key = 0
      end,
    },
    {-- key = 3
      function(state)
        state.active_paramSet = state.paramSet
        state.active_param = 2
        state.key = 0
      end,
      function(state)
        state.active_param = 3
        state.key = 0
      end
    }
  },
  {-- VIEW 6 - she - edit loop settings
    {-- key = 1
      
    },
    {-- key = 2
      function(state)
        state.view = 3
        state.key = 0
      end
    },
    {-- key = 3
      
    }
  },
  {-- VIEW 7 - she - edit external io settings
    {-- key = 1
      
    },
    {-- key = 2
      function(state)
        state.view = 3
        state.key = 0
      end
    },
    {-- key = 3
      
    }
  } 
}

function do_key_action(state, n)
  handler = state.active_param > 1 and 2 or 1
  
  -- print('before key action', 'view: ' .. state.view, 'active_paramSet: ' .. state.active_paramSet, 'handler: ' .. state.active_param)
  
  if key_actions[state.view][n][handler] ~= nil then key_actions[state.view][n][handler](state) end
  
  -- print('before key action', 'view: ' .. state.view, 'active_paramSet: ' .. state.active_paramSet, 'handler: ' .. state.active_param)
end

return do_key_action