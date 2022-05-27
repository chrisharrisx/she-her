--
--    
--        
--            she/her

local er = require 'er'

-- thanks to @tehn, @justmat
--

tracks = include('lib/tracks')
engine.name = 'PolyPerc'

local Globals = include('lib/globals')
local View = include('lib/view')
local GridUtil = include('lib/grid_util')
local MusicUtil = require "musicutil"

local do_enc_action = include('lib/enc')
local do_key_action = include('lib/key')

local g = grid.connect()

local midi_out1 = midi.connect(1)
local midi_out2 = midi.connect(2)
local midi_out3 = midi.connect(3)
local midi_out4 = midi.connect(4)
-- local midi_in = midi.connect(2)

local midi_connections = {
  midi_out1,
  midi_out2,
  midi_out3,
  midi_out4
}

local clear

local state = {
  active_track = 1,
  track_1_root = 60,
  track_1_chord = 1,
  update_chord = 0,
  update_followers = false,
  globals = Globals,
  active_global = 1,
  paramSet = 1,
  active_paramSet = 1,
  active_param = 1,
  active_octave_step = 0,
  view = 1,
  key = 1,
  keys = { 0, 0, 0 },
  alt = 0,
  sync = 0, -- clock for quantizing loop on/off
  reset = 0,
  external = 1
}

local pulses, root, octave, fixed_velocity = 1, 1, 1, 1
local division, chord, velocity_randomization = 2, 2, 2
local trig_probability = 3
local note_randomization, play_chord = 4, 4

function rerun()
  norns.script.load(norns.state.script)
end

function init()
  print('she/her')
  
  GridUtil.init(g)
  
  state.globals.loadstate(1) -- TODO read saved slot to load from file instead of hard-coding
  
  params:set("clock_tempo", state.globals.get_tempo())

  clock.run(tick, 1)
  clock.run(tick, 2)
  clock.run(tick, 3)
  clock.run(tick, 4)
  
  -- midi_in.event = midi_event
end

function tick(trackNum)
  while true do
    clock.sync(tracks[trackNum]:get_division_value())
    GridUtil.update_trigs(g)
    read_from_track(trackNum)
      
    if tracks[state.globals.get_chain_position()]:get_position() == 1 then
      if state.globals.get_chain_position() < #tracks then
        state.globals.set_chain_position(state.globals.get_chain_position() + 1)
      else
        state.globals.set_chain_position(1)
      end
    end
      
    redraw()
  end
end

function read_from_track(trackNum)
  position = tracks[trackNum]:get_position()
  octave_position = tracks[trackNum]:get_octave_position()
  trig = tracks[trackNum]:get_steps()[position]
  velocity = tracks[trackNum]:get_velocity_randomization()
  fixed_velocity = tracks[trackNum]:get_fixed_velocity()
  velocity = velocity < math.random(100) and fixed_velocity or math.random(10, tracks[trackNum]:get_max_velocity())
  -- velocity = (state.globals.get_chain() and state.globals.get_chain_position() == trackNum) and velocity or 0
  channel = tracks[trackNum].midi_channel
  out = tracks[trackNum].midi_output
  
  if trig == true and math.random(100) <= tracks[trackNum]:get_trig_probability() then
    -- CHANNEL SHIFT REGISTER
    if tracks[trackNum].midi_channel < tracks[trackNum].midi_end_channel then
      tracks[trackNum].midi_channel = tracks[trackNum].midi_channel + 1
    else
      tracks[trackNum].midi_channel = tracks[trackNum].midi_start_channel
    end
    
    -- MIDI OUTPUT SHIFT REGISTER
    if tracks[trackNum].midi_output < tracks[trackNum].midi_end_output then
      tracks[trackNum].midi_output = tracks[trackNum].midi_output + 1
    else
      tracks[trackNum].midi_output = tracks[trackNum].midi_start_output
    end

    -- OUTPUT MIDI
    if tracks[trackNum]:get_play_mode() == play_chord and tracks[trackNum]:get_chord() ~= 1 then
      notes = tracks[trackNum]:get_notes(state)
      for i = 1, #notes do
        if tracks[trackNum].send == 1 then
          midi_connections[tracks[trackNum].midi_output]:note_on(notes[i], velocity, channel)
        elseif tracks[trackNum].send == 5 then
          engine.hz(MusicUtil.note_num_to_freq(notes[i]))
        else
          midi_connections[tracks[trackNum].midi_output]:cc(11, notes[i], 2)
        end
      end
    else
      note_to_play = tracks[trackNum]:get_notes(state)
      if tracks[trackNum].send == 1 then
        -- print(midi_connections, tracks[trackNum].midi_output)
        midi_connections[tracks[trackNum].midi_output]:note_on(note_to_play, velocity, channel)
      elseif tracks[trackNum].send == 5 then
        engine.hz(MusicUtil.note_num_to_freq(note_to_play))
      else
        midi_connections[tracks[trackNum].midi_output]:cc(11, note_to_play, 2)
      end
    end
  end
  
  tracks[trackNum]:set_position(position < tracks[trackNum]:get_length() and position + 1 or 1)
  tracks[trackNum]:set_octave_position(octave_position < tracks[trackNum]:get_octave_length() and octave_position + 1 or 1)
  
  if trackNum == 1 and tracks[trackNum]:get_position() == 1 then
    current_cycle = state.globals.get_chord_cycle()
    if current_cycle <= state.globals.get_chord_interval() then
      state.globals.set_chord_cycle(current_cycle + 1)
    else
      state.globals.set_chord_cycle(1)
    end
    if state.globals.get_chord_cycle() == 1 and state.globals.get_chord_chance() > 0 then
      tracks[1]:change_chord(state)
    end
  end
end

function redraw()
  View.views[state.view](state)
end

function key(n, z)
  state.key = n
  state.alt = z
  state.keys[n] = z
  
  if state.keys[1] == 1 and state.keys[2] == 1 and state.keys[3] == 1 then
    state.reset = clock.run(tracks.reset, state.reset) -- sync read heads
    for i = 1, #state.keys do
      state.keys[i] = 0
    end
    return
  end
  
  if z ~= 1 and state.keys[1] ~= 1 then
    do_key_action(state, n)
  end
  
  redraw()
end

function enc(n, d)
  do_enc_action(state, n, d)
  redraw()
end

function g.key(x, y, z)
  -- g:led(x, y, state == 1 and 10 or 0)
  -- g:refresh()
  
  if y == 1 and z == 0 then
    g:led(x, y, tracks[1]:get_step(x) and 2 or 6)
    g:refresh()
    tracks[1]:set_step(x)
  end
  
  if y == 8 and x <= 4 and z == 0 then
    tracks[x]:toggle_mute()
    GridUtil.update_mutes(g)
    g:refresh()
  end
end

function midi_event(data)
  local msg = midi.to_msg(data)
  
  active_track = tracks[state.active_track]
  numPulses = active_track:get_pulses()
  numSteps = active_track:get_length()
  
  -- if msg.type == "note_on" then
  --   print(msg.note)
  -- end
  
  if msg.type == 'cc' then
    -- print(msg.cc, msg.val)
    if msg.cc == 59 then
      value = math.ceil((msg.val / 127) * 16)
      numPulses = numPulses + value
      active_track:set_steps(er.gen(numPulses, numSteps, 0)) -- change these to do_enc_action?
    elseif msg.cc == 60 then
      value = math.ceil((msg.val / 127) * 3) + 1
      active_track:set_play_mode(value)
    end
    
    redraw()
  end
end