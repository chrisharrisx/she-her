--
--    
--        
--            she/her

local er = require 'er'

local Tracks = include('lib/tracks')
local View = include('lib/view')
local Globals = include('lib/globals')
local Buffer = include('lib/buffer')

local do_enc_action = include('lib/enc')
local do_key_action = include('lib/key')

local midi_out1 = midi.connect(1)
local midi_out2 = midi.connect(2)
-- local midi_in = midi.connect(2)

local midi_connections = {
  midi_out1,
  midi_out2
}

local state = {
  tracks = Tracks,
  active_track = 1,
  track_1_root = 60,
  track_1_chord = 1,
  update_chord = 0,
  update_followers = false,
  buffer = Buffer,
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
  reset = 0
}

local pulses, root, octave, fixed_velocity = 1, 1, 1, 1
local division, chord, velocity_randomization = 2, 2, 2
local trig_probability = 3
local note_randomization, play_chord = 4, 4

started_chaining = false

function init()
  params:set("clock_tempo", state.globals.get_tempo())

  clock.run(tick, 1)
  clock.run(tick, 2)
  clock.run(tick, 3)
  clock.run(tick, 4)
  
  -- midi_in.event = midi_event
end

function tick(trackNum)
  while true do
    clock.sync(state.tracks[trackNum]:get_division_value())
  
    if state.globals.chain() and trackNum == 1 then
      -- chain mode
      local chain_position = state.globals.get_chain_position()
      local active_track = state.tracks[chain_position]
      if state.buffer.loop == 0 then
        read_from_track(chain_position)
        if active_track:get_position() == active_track:get_length() then
          if chain_position < #state.tracks then
            state.globals.set_chain_position(chain_position + 1)
          else
            state.globals.set_chain_position(1)
          end
        end
      else
        read_from_buffer(chain_position)
      end
    elseif not state.globals.chain() then
      -- normal mode
      if state.buffer.loop == 0 then
        read_from_track(trackNum)
      else
        read_from_buffer(trackNum)
      end
    end
    redraw()
  end
end

function read_from_track(trackNum)
  position = state.tracks[trackNum]:get_position()
  octave_position = state.tracks[trackNum]:get_octave_position()
  trig = state.tracks[trackNum]:get_steps()[position]
  velocity = state.tracks[trackNum]:get_velocity_randomization()
  fixed_velocity = state.tracks[trackNum]:get_fixed_velocity()
  velocity = velocity < math.random(100) and fixed_velocity or math.random(10, state.tracks[trackNum]:get_max_velocity())
  -- velocity = (state.globals.get_chain() and state.globals.get_chain_position() == trackNum) and velocity or 0
  channel = state.tracks[trackNum].midi_channel
  out = state.tracks[trackNum].midi_output
  
  if trig == true and math.random(100) <= state.tracks[trackNum]:get_trig_probability() then
    if state.tracks[trackNum].midi_channel < state.tracks[trackNum].midi_end_channel then
      state.tracks[trackNum].midi_channel = state.tracks[trackNum].midi_channel + 1
    else
      state.tracks[trackNum].midi_channel = state.tracks[trackNum].midi_start_channel
    end
    
    if state.tracks[trackNum].midi_output < state.tracks[trackNum].midi_end_output then
      state.tracks[trackNum].midi_output = state.tracks[trackNum].midi_output + 1
    else
      state.tracks[trackNum].midi_output = state.tracks[trackNum].midi_start_output
    end
    
    if state.tracks[trackNum]:get_play_mode() == play_chord and state.tracks[trackNum]:get_chord() ~= 1 then
      notes = state.tracks[trackNum]:get_notes(state)
      for i = 1, #notes do
        if state.tracks[trackNum].send == 1 then
          midi_connections[state.tracks[trackNum].midi_output]:note_on(notes[i], velocity, channel)
        else
          -- midi_out1:cc(23, notes[i], 1)
        end
      end
      state.buffer.write_buffer(trackNum, { notes, velocity, channel, out })
    else
      note_to_play = state.tracks[trackNum]:get_notes(state)
      state.buffer.write_buffer(trackNum, { note_to_play, velocity, channel, out })
      if state.tracks[trackNum].send == 1 then
        midi_connections[state.tracks[trackNum].midi_output]:note_on(note_to_play, velocity, channel)
      else
        -- midi_out1:cc(23, note_to_play, 1)
      end
    end
  else
    state.buffer.write_buffer(trackNum, {})
  end
  
  state.buffer.advance(trackNum)
  state.tracks[trackNum]:set_position(position < state.tracks[trackNum]:get_length() and position + 1 or 1)
  state.tracks[trackNum]:set_octave_position(octave_position < state.tracks[trackNum]:get_octave_length() and octave_position + 1 or 1)
  
  if trackNum == 1 and state.tracks[trackNum]:get_position() == 1 then
    current_cycle = state.globals.get_chord_cycle()
    if current_cycle <= state.globals.get_chord_interval() then
      state.globals.set_chord_cycle(current_cycle + 1)
    else
      state.globals.set_chord_cycle(1)
    end
    if state.globals.get_chord_cycle() == 1 and state.globals.get_chord_chance() > 0 then
      state.tracks[1]:change_chord(state)
    end
  end
end

function read_from_buffer(trackNum)
  values = state.buffer.read_buffer(trackNum)
  if values ~= nil and #values > 1 then
    note = values[1]
    velocity = values[2]
    channel = values[3]
    out = values[4]
    if type(note) == 'table' then
      for i = 1, #note do
        if state.tracks[trackNum].send == 1 then
          midi_connections[out]:note_on(note[i], velocity, channel)
        else
          -- midi_out1:cc(23, note[i], 1)
        end
      end
    else
      if type(note) == 'table' then
        arp_position = state.tracks[trackNum]:get_octave_position()
        if state.tracks[trackNum].send == 1 then
          -- midi_out1:note_on(note[arp_position], velocity, channel)
          midi_connections[out]:note_on(note[arp_position], velocity, channel)
        else
          -- midi_out1:cc(23, note[arp_position], 1)
        end
      else
        if state.tracks[trackNum].send == 1 then
          -- midi_out1:note_on(note, velocity, channel)
          midi_connections[out]:note_on(note, velocity, channel)
        else
          -- midi_out1:cc(23, note, 1)
        end
      end
    end
  end
  state.buffer.advance(trackNum)
  state.tracks[trackNum]:set_position(position < state.tracks[trackNum]:get_length() and position + 1 or 1)
  state.tracks[trackNum]:set_octave_position(octave_position < state.tracks[trackNum]:get_octave_length() and octave_position + 1 or 1)
end

function redraw()
  View.views[state.view](state)
end

function key(n, z)
  state.key = n
  state.alt = z
  state.keys[n] = z
  if state.keys[1] == 1 and state.keys[2] and state.keys[3] == 1 then
    Buffer.clear()
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

function midi_event(data)
  local msg = midi.to_msg(data)
  
  active_track = state.tracks[state.active_track]
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