buffer = include('lib/buffer')
tracks = include('lib/tracks')

local ChordUtil = include('lib/chord_util')
local HarmonyUtil = include('lib/harmony_util')
local MusicUtil = require('musicutil')

local View = {}

local x_start = 2
local y_start = 10
local current_x = x_start
local current_y = y_start

function View.her(state)
  screen.clear()
  
  for i = 1, #tracks do
    screen.move(x_start, 10 * i)
    screen.level(i == state.active_track and 15 or 2)
    screen.text(tracks[i].title)
  end
  
  current_x = 65
  current_y = 40
  screen.move(current_x, current_y)
  
  -- screen.level(state.active_option == 5 and state.edit_tempo == false and 15 or 2)
  -- screen.text('tempo ')
  -- screen.level(state.active_option == 5 and state.edit_tempo and 15 or 2)
  -- screen.text(state.tempo)
  
  screen.level(4)
  screen.font_face(13)
  screen.font_size(40)
  screen.text('her')
  screen.font_face(1) -- reset
  screen.font_size(8)
  
  View.displayTouringParams(state)
  
  screen.update()
end

function View.trackEdit(state)
  current_x = x_start
  current_y = y_start
  active_track = tracks[state.active_track]
  screen.clear()
  screen.move(x_start, 10)
  
  View.displayStepParams(state, active_track)
  View.displayOctaveParams(state, active_track)
  View.displayNoteParams(state, active_track)
  View.displayVelocityParams(state, active_track)
  View.displayTouringParams(state)
  
  screen.update()
end

function View.displayStepParams(state, active_track)
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text(active_track:get_stepParams().title)
  
  current_x = 35
  screen.move(current_x, current_y)
  
  -- steps
  for i = 1, active_track:get_length() do
    if state.active_paramSet == 1 and state.active_param == 2 then
      screen.level(i == active_track:get_position() and 3 or 8)
    else
      screen.level(i == active_track:get_position() and 7 or 2)
    end
    
    screen.line_rel(0, active_track:get_steps()[i] and -6 or -2)
    screen.stroke()
    current_x = current_x + 3
    screen.move(current_x, current_y)
  end
  
  -- division
  division = active_track.divisions[active_track:get_division()].displayValue
  screen.move(90, current_y)
  screen.level(state.active_paramSet == 1 and state.active_param == 3 and 15 or 2)
  screen.text(division)
  
  -- trig probability
  probability = active_track:get_trig_probability()
  screen.move(110, current_y)
  screen.level(state.active_paramSet == 1 and state.active_param >= 4 and 15 or 2)
  screen.text('%' .. probability)
  
  current_x = x_start -- reset
end

function View.displayOctaveParams(state, active_track)
  current_y = current_y + 10
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 2 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text(active_track:get_octaveParams().title)
  
  starting_y = current_y
  middle_y = current_y - 1
  
  current_x = 35
  current_y = middle_y
  screen.move(current_x, current_y)
  
  -- shift steps
  for i = 1, active_track:get_octave_length() do
    if i == state.active_octave_step then
      screen.level(15)
    elseif i == active_track:get_octave_position() then
      screen.level(7)
    else
      screen.level(2)
    end
    
    offset = active_track:get_shift_step_multiple(i)
    current_y = middle_y - offset
    screen.move(current_x, current_y)
    
    screen.line_rel(0, -2)
    screen.stroke()
    current_x = current_x + 3
    screen.move(current_x, -2)
  end
  
  -- shift amount
  amount = active_track:get_chord() > 2 and ChordUtil.chord_shifts[active_track:get_track_shift() - 1] or ChordUtil.shifts[active_track:get_track_shift() - 1]
  if state.active_octave_step ~= 0 then
    amount = active_track:get_chord() > 2 and ChordUtil.chord_shifts[active_track:get_shift_step_degree(state.active_octave_step) - 1]  or ChordUtil.shifts[active_track:get_shift_step_degree(state.active_octave_step) - 1]
  end
  screen.move(90, 20)
  if not (state.paramSet == 2 and state.active_paramSet == 2 and state.active_param == 3) then
    screen.level(2)
  else
    screen.level(15)
    amount = active_track:get_chord() > 2 and ChordUtil.chord_shifts[active_track:get_track_shift() - 1] or ChordUtil.shifts[active_track:get_track_shift() - 1]
  end
  screen.text(amount)
  
  current_x = x_start
  current_y = starting_y
end

function View.displayNoteParams(state, active_track)
  current_y = current_y + 10
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 3 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text(active_track:get_noteParams().title)
  
  current_x = 35
  screen.move(current_x, current_y)
  
  -- root note
  root = active_track:get_root_name()
  screen.level(state.active_paramSet == 3 and state.active_param == 2 and 15 or 2)
  screen.text(root)
  
  current_x = 58
  screen.move(current_x, current_y)
  
  -- chord
  chord = active_track:get_chord_name()
  screen.level(state.active_paramSet == 3 and state.active_param == 3 and 15 or 2)
  screen.text(chord)
  
  current_x = 90
  screen.move(current_x, current_y)
  
  -- chord type
  play_mode = active_track:get_play_mode_name()
  screen.level(state.active_paramSet == 3 and state.active_param == 4 and 15 or 2)
  screen.text(play_mode)
  
  current_x = 110
  screen.move(current_x, current_y)
  
  -- note randomization
  -- probability = active_track:get_note_randomization()
  -- screen.level(state.active_paramSet == 3 and state.active_param == 4 and 15 or 2)
  -- screen.text('%' .. probability)
  
  current_x = x_start
end

function View.displayVelocityParams(state, active_track)
  current_y = current_y + 10
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 4 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text(active_track:get_velocityParams().title)
  
  current_x = 35
  screen.move(current_x, current_y)
  
  -- fixed velocity
  v = active_track:get_fixed_velocity()
  screen.level(state.active_paramSet == 4 and state.active_param == 2 and 15 or 2)
  screen.text(v)
  
  current_x = 58
  screen.move(current_x, current_y)
  -- max velocity when randomized
  mv = active_track:get_max_velocity()
  screen.level(state.active_paramSet == 4 and state.active_param == 3 and 15 or 2)
  screen.text(mv)
  
  current_x = 90
  screen.move(current_x, current_y)
  -- velocity randomization
  r = active_track:get_velocity_randomization()
  screen.level(state.active_paramSet == 4 and state.active_param == 4 and 15 or 2)
  screen.text('%' .. r)
end

function View.she(state)
  screen.clear()
  
  current_x = x_start
  current_y = 40
  screen.move(current_x, current_y)
  
  screen.level(4)
  screen.font_face(13)
  screen.font_size(40)
  screen.text('she')
  screen.font_face(1) -- reset
  screen.font_size(8)
  
  current_x = 80
  current_y = y_start
  screen.move(current_x, current_y)
  
  for i = 1, #state.globals.paramSets do
    screen.move(current_x, current_y + (10 * (i - 1)))
    screen.level(i == state.active_global and 15 or 2)
    screen.text(state.globals.paramSets[i].title)
  end

  -- View.sequenceEdit(state)
  -- View.harmonyEdit(state)
  -- View.externalEdit(state)
  View.displayTouringParams(state)
  
  screen.update()
end

-------------------------------------------------------------------------

function View.sequenceEdit(state)
  screen.clear()

  -- tempo
  current_x = x_start
  current_y = y_start
  screen.move(current_x, current_y)
  
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('tempo')
  
  current_x = 35
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 2 and 15 or 2)
  screen.text(state.globals.get_tempo())

  -- mode
  current_x = x_start
  current_y = 20
  screen.move(current_x, current_y)

  screen.level(state.paramSet == 2 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('mode')

  current_x = 35
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 2 and state.active_paramSet == 2 and state.active_param == 2 and 15 or 2)
  mode = state.globals.get_sequence_mode() == 0 and 'normal' or 'chain'
  screen.text(mode)

  -- reset
  current_x = x_start
  current_y = 30
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 3 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('reset')
  
  screen.update()
end

--------------------------------------------------------------------------

function View.harmonyEdit(state)
  screen.clear()
  
  current_x = x_start
  current_y = y_start
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('follow')
  follow = state.globals.get_follow_state()
  screen.move(58, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 2 and 15 or 2)
  screen.text(follow == 1 and 'on' or 'off')
  
  current_x = x_start
  current_y = 20
  screen.move(current_x, current_y)
  -- key / transpose
  screen.level(state.paramSet == 2 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('key')

  current_x = 58
  screen.move(current_x, current_y)
  k = state.globals.get_key()
  screen.level(state.paramSet == 2 and state.active_paramSet == 2 and state.active_param == 2 and 15 or 2)
  screen.text(MusicUtil.note_num_to_name(k))
  
  current_x = x_start
  current_y = 30
  screen.move(current_x, current_y)
  -- chance of key change
  screen.level(state.paramSet == 3 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('key mod')
  
  current_x = 58
  screen.move(current_x, current_y)
  -- chance of key change
  -- ch = state.globals.get_chord_chance()
  kch = 0
  screen.level(state.paramSet == 3 and state.active_paramSet == 3 and state.active_param == 2 and 15 or 2)
  screen.text('%' .. kch)
  
  current_x = 90
  screen.move(current_x, current_y)
  -- frequency of key change
  -- cf = state.globals.get_chord_interval()
  -- cf = cf == 0 and 'x' or cf
  cf = 'x'
  screen.level(2)
  screen.text('every ')
  screen.level(state.paramSet == 3 and state.active_paramSet == 3 and state.active_param == 3 and 15 or 2)
  screen.text(cf)
  
  current_x = x_start
  current_y = 40
  screen.move(current_x, current_y)
  -- random chord changes
  screen.level(state.paramSet == 4 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('chord mod')
  
  current_x = 58
  screen.move(current_x, current_y)
  -- chance of chord change
  ch = state.globals.get_chord_chance()
  screen.level(state.paramSet == 4 and state.active_paramSet == 4 and state.active_param == 2 and 15 or 2)
  screen.text('%' .. ch)
  
  current_x = 90
  screen.move(current_x, current_y)
  -- frequency of chord change
  cf = state.globals.get_chord_interval()
  cf = cf == 0 and 'x' or cf
  screen.level(2)
  screen.text('every ')
  screen.level(state.paramSet == 4 and state.active_paramSet == 4 and state.active_param == 3 and 15 or 2)
  screen.text(cf)
  
  screen.update()
end

-- function View.loopEdit(state)
--   screen.clear()
  
--   current_x = x_start
--   current_y = y_start
--   screen.move(current_x, current_y)
--   screen.level(state.paramSet == 3 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
--   screen.text('loop settings')
  
--   screen.update()
-- end

function View.externalEdit(state)
  screen.clear()
  
  current_x = x_start
  current_y = y_start
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 4 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('external io settings')
  
  screen.update()
end

function View.saveLoadEdit(state)
  screen.clear()
  
  current_x = x_start
  current_y = y_start
  screen.move(current_x, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 1 and 15 or 2)
  screen.text('save')
  
  screen.move(58, current_y)
  screen.level(state.paramSet == 1 and state.active_paramSet == 1 and state.active_param == 2 and 15 or 2)
  screen.text('slot ' .. state.globals.save_slot)
  
  screen.update()
end

function View.confirmSave(state)
  screen.clear()
  
  current_x = x_start
  current_y = 20
  screen.move(current_x, current_y)
  
  screen.level(4)
  screen.font_face(13)
  screen.font_size(16)
  screen.text('confirm save?')
  screen.font_face(1) -- reset
  screen.font_size(8)
  screen.move(current_x, 40)
  screen.text('k2 to confirm, k3 to cancel')
  
  screen.update()
end

function View.displayTouringParams(state)
  current_x = x_start
  current_y = 60
  screen.move(current_x, current_y)
  screen.level(2)
  screen.text('len: ' .. buffer.length)
  
  screen.move(40, current_y)
  screen.text('start: ' .. buffer.start)
  
  screen.move(90, current_y)
  screen.text('loop: ' .. buffer.loop_states[buffer.loop + 1])
end

View.views = {
  View.her,
  View.trackEdit,
  View.she,
  View.sequenceEdit,
  View.harmonyEdit,
  View.externalEdit,
  View.saveLoadEdit,
  View.confirmSave
}

return View