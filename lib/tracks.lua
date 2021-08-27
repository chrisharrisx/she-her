local er = require 'er'

local Track = {}
local ChordUtil = include('lib/chord_util')
local HarmonyUtil = include('lib/harmony_util')
local MusicUtil = require "musicutil"

local stepParams, steps, rootNote, octaveSteps, fixedVelocity, arpUp, multiple = 1, 1, 1, 1, 1, 1, 1
local octaveParams, div, chord, shiftAmount, maxVelocity, arpDown, degree = 2, 2, 2, 2, 2, 2, 2
local noteParams, trig_prob, play_mode, velocityRandomization, arpRand = 3, 3, 3, 3, 3
local velocityParams, inversion, noArp = 4, 4, 4

local gettingRoot = 1
local settingRoot = 1

function Track:create(title, start_chan, end_chan, start_out, end_out, msg_type) 
  self.__index = self
  return setmetatable({
    title = title,
    midi_channel = start_chan,
    midi_start_channel = start_chan,
    midi_end_channel = end_chan,
    midi_output = start_out,
    midi_start_output = start_out,
    midi_end_output = end_out,
    send = msg_type,
    paramSets = {
      {
        title = 'steps',
        position = 1,
        pulses = 0,
        rotation = 0,
        values = {
          { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }, -- steps
          5, -- step division
          100 -- trig probability
        }
      },
      {
        title = 'shift',
        track_shift = 13,
        chord_track_shift = 8,
        position = 1,
        length = 16,
        preset = 0,
        values = {
          { {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13} }, -- shift steps
          8
        },
        chord_values = {
          {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}, {0,13}
        }
      },
      {
        title = 'notes',
        arp_position = 0,
        values = {
          60, -- root note
          2, -- chord
          1 -- play mode { 'arpU', 'arpD', 'arpR', 'chord' }
        }
      },
      {
        title = 'vel',
        values = {
          64, -- fixed velocity
          127, -- max velocity for randomization
          0 -- velocity randomization
        }
      }
    },
    get_steps = function(self)
      return self.paramSets[stepParams].values[steps]
    end,
    set_steps = function(self, s)
      self.paramSets[stepParams].values[steps] = s
    end,
    print_steps = function(self)
      stepvalues = '{'
      for i = 1, #self.paramSets[stepParams].values[steps] do
        stepvalue = self.paramSets[stepParams].values[steps][i] and 1 or 0
        stepvalues = stepvalues .. stepvalue .. ','
      end
      stepvalues = stepvalues .. '}'
      return stepvalues
    end,
    restore_steps = function(self, p)
      self.paramSets[stepParams].values[steps] = nil
      self.paramSets[stepParams].values[steps] = {}
      
      count = 0
      for i = 1, #p do
        if p[i] == 0 then
          self.paramSets[stepParams].values[steps][i] = false
        else
          self.paramSets[stepParams].values[steps][i] = true
          count = count + 1
        end
      end
      self:set_pulses(count)
    end,
    get_length = function(self)
      return #self.paramSets[stepParams].values[steps]
    end,
    get_position = function(self)
      return self.paramSets[stepParams].position
    end,
    set_position = function(self, position)
      self.paramSets[stepParams].position = position
    end,
    get_pulses = function(self)
      return self.paramSets[stepParams].pulses
    end,
    set_pulses = function(self, numPulses)
      self.paramSets[stepParams].pulses = numPulses  
    end,
    get_division = function(self)
      return self.paramSets[stepParams].values[div]
    end,
    set_division = function(self, division)
      self.paramSets[stepParams].values[div] = division
    end,
    get_division_value = function(self)
      return Track.divisions[self.paramSets[stepParams].values[div]].value
    end,
    get_trig_probability = function(self)
      return self.paramSets[stepParams].values[trig_prob]
    end,
    set_trig_probability = function(self, probability)
      self.paramSets[stepParams].values[trig_prob] = probability
    end,
    get_rotation = function(self)
      return self.paramSets[stepParams].rotation
    end,
    set_rotation = function(self, rotate)
      self.paramSets[stepParams].rotation = rotate
    end,
    apply_rotation = function(self, rotate)
      self:set_steps(er.gen(self:get_pulses(), self:get_length(), rotate))
    end,
    get_stepParams = function(self)
      return self.paramSets[stepParams]
    end,
    get_octaveParams = function(self)
      return self.paramSets[octaveParams]
    end,
    get_noteParams = function(self)
      return self.paramSets[noteParams]
    end,
    get_velocityParams = function(self)
      return self.paramSets[velocityParams]
    end,
    get_track_shift = function(self)
      if self:get_chord() > 2 then
        return self.paramSets[octaveParams].chord_track_shift
      else
        return self.paramSets[octaveParams].track_shift
      end
    end,
    set_track_shift = function(self, s)
      if self:get_chord() > 2 then
        self.paramSets[octaveParams].chord_track_shift = s
        for i = 1, #self.paramSets[octaveParams].chord_values do
          if self.paramSets[octaveParams].chord_values[i][multiple] == 0 then
            self.paramSets[octaveParams].chord_values[i][degree] = s
          end
        end
      else
        self.paramSets[octaveParams].track_shift = s
        for i = 1, #self.paramSets[octaveParams].values[octaveSteps] do
          if self.paramSets[octaveParams].values[octaveSteps][i][multiple] == 0 then
            self.paramSets[octaveParams].values[octaveSteps][i][degree] = s
          end
        end
      end
    end,
    get_octave_step = function(self, oct)
      if self.paramSets[noteParams].values[chord] > 2 then
        return self.paramSets[octaveParams].chord_values[oct][multiple]
      else
        return self.paramSets[octaveParams].values[octaveSteps][oct][multiple]
      end
    end,
    set_octave_step = function(self, oct, mult, d)
      if self:get_chord() > 2 then
        self.paramSets[octaveParams].chord_values[oct][multiple] = mult
        self.paramSets[octaveParams].chord_values[oct][degree] = d
      else
        self.paramSets[octaveParams].values[octaveSteps][oct][multiple] = mult
        self.paramSets[octaveParams].values[octaveSteps][oct][degree] = d
      end
    end,
    get_shift_step_degree = function(self, oct)
      if self.paramSets[noteParams].values[chord] > 2 then
        return self.paramSets[octaveParams].chord_values[oct][degree]
      else
        return self.paramSets[octaveParams].values[octaveSteps][oct][degree]
      end
    end,
    set_shift_step_degree = function(self, oct, d)
      if self.paramSets[noteParams].values[chord] > 2 then
        self.paramSets[octaveParams].chord_values[oct][degree] = d
      else
        self.paramSets[octaveParams].values[octaveSteps][oct][degree] = d
      end
    end,
    get_shift_step_multiple = function(self, step)
      if self.paramSets[noteParams].values[chord] > 2 then
        return self.paramSets[octaveParams].chord_values[step][multiple]
      else
        return self.paramSets[octaveParams].values[octaveSteps][step][multiple]
      end
    end,
    set_shift_step_multiple = function(self, step, m)
      if self.paramSets[noteParams].values[chord] > 2 then
        self.paramSets[octaveParams].chord_values[step][multiple] = m
      else
        self.paramSets[octaveParams].values[octaveSteps][step][multiple] = m
      end
    end,
    get_octave_length = function(self)
      return self.paramSets[octaveParams].length
      -- return #self.paramSets[octaveParams].values[octaveSteps]
    end,
    set_octave_length = function(self, len)
      self.paramSets[octaveParams].length = len
    end,
    set_octave_steps = function(self, state, d)
      default_value = self:get_track_shift()
      
      if d < 0 then
        self:set_shift_preset(0)
        t = self:get_chord() > 2 and self.paramSets[octaveParams].chord_values or self.paramSets[octaveParams].values[octaveSteps]
        self:delete_octave_steps(state, d, default_value, t)
      else
        self:set_shift_preset(util.clamp(self:get_shift_preset() + d, 0, #Track.shift_presets))
        if self:get_chord() > 2 then
          self.paramSets[octaveParams].chord_values = nil
          self.paramSets[octaveParams].chord_values = self:get_preset_steps()
        else
          self.paramSets[octaveParams].values[octaveSteps] = nil
          self.paramSets[octaveParams].values[octaveSteps] = self:get_preset_steps()
        end
      end
    end,
    delete_octave_steps = function(self, state, d, default_value, target)
      for i = 1, #target do
        val = self:get_octave_step(i)
        if val >= 1 then
          self:set_octave_step(i, val + d, default_value)
        elseif val <= -1 then
          self:set_octave_step(i, val - d, default_value)
        end
      end
    end,
    get_preset_steps = function(self)
      p = self:get_shift_preset()
      temp = {}
      for i = 1, #Track.shift_presets[p] do
        table.insert(temp, { Track.shift_presets[p][i], self:get_track_shift() })
      end
      return temp
    end,
    get_shift_preset = function(self)
      return self.paramSets[octaveParams].preset
    end,
    set_shift_preset = function(self, p)
      self.paramSets[octaveParams].preset = p
    end,
    get_octave_steps = function(self)
      return self.paramSets[octaveParams].values[octaveSteps]
    end,
    get_octave_position = function(self)
      return self.paramSets[octaveParams].position
    end,
    set_octave_position = function(self, position)
      self.paramSets[octaveParams].position = position
    end,
    get_shift_amount = function(self)
      return self.paramSets[octaveParams].values[shiftAmount]
    end,
    set_shift_amount = function(self, number)
      self.paramSets[octaveParams].values[shiftAmount] = number
    end,
    get_root_note = function(self)
      return self.paramSets[noteParams].values[rootNote]
    end,
    set_root_note = function(self, number)
      if number <= 127 and number >= 0 then
        self.paramSets[noteParams].values[rootNote] = number
      end
    end,
    get_root_name = function(self)
      root = self.paramSets[noteParams].values[rootNote]
      return ChordUtil.getNoteNameForNumber(root)
    end,
    get_chord = function(self)
      return self.paramSets[noteParams].values[chord]
    end,
    set_chord = function(self, number)
      self.paramSets[noteParams].values[chord] = number
    end,
    get_chord_name = function(self, number)
      ch = self.paramSets[noteParams].values[chord]
      return ChordUtil.getChordNameForNumber(ch)
    end,
    get_play_mode = function(self)
      return self.paramSets[noteParams].values[play_mode]
    end,
    set_play_mode = function(self, number)
      self.paramSets[noteParams].values[play_mode] = number
    end,
    get_play_mode_name = function(self)
      pm = self.paramSets[noteParams].values[play_mode]
      return ChordUtil.playMode[pm]
    end,
    get_chord_inversion = function(self)
      return self.paramSets[noteParams].values[inversion]
    end,
    set_chord_inversion = function(self, number)
      self.paramSets[noteParams].values[inversion] = number
    end,
    get_arp_position = function(self)
      return self.paramSets[noteParams].arp_position
    end,
    set_arp_position = function(self, length, t)
      if t == arpUp then
        if self.paramSets[noteParams].arp_position < length then
          self.paramSets[noteParams].arp_position = self.paramSets[noteParams].arp_position + 1
        else
          self.paramSets[noteParams].arp_position = 1
        end
      elseif t == arpDown then
        if self.paramSets[noteParams].arp_position > 1 then
          self.paramSets[noteParams].arp_position = self.paramSets[noteParams].arp_position - 1
        else
          self.paramSets[noteParams].arp_position = length
        end
      elseif t == arpRand then
        rand = math.ceil(math.random() * length)
        self.paramSets[noteParams].arp_position = rand
      end
    end,
    change_chord = function(self, state)
    --[[  At the interval specified, generate a new root and chord for track 1
          (unless track 1 chord type is set to fixed).
          If track 1 chord type is set to root, only a new root will be generated, chord type will stay fixed.
          Followers will simultaneously update with:
            – a new root unless chord type of follower is set to fixed
            – a new chord if track 1 chord type AND follower chord type are not set to root or fixed  --]]
      
      if (state.active_paramSet == 3 and state.active_param ~= 3) or state.active_paramSet ~= 3  then
        k = state.globals.get_key()
        r = self:get_root_note()
        c = self:get_chord()
        
        if math.random(100) <= state.globals.get_chord_chance() and c > 1 and self.title == 'track 1' then
          change = HarmonyUtil.getRandDiatonicChordChange(state)
          
          if change ~= nil then
            current_root = state.tracks[1]:get_root_note()
            current_octave = ChordUtil.getOctaveOfRoot(current_root)
            new_root = change[1]
            new_octave = ChordUtil.getOctaveOfRoot(new_root)
            octave_diff = current_octave - new_octave
            
            n = new_root + (12 * octave_diff)
            self:set_root_note(n)
            state.track_1_root = new_root
            
            if c > 2 then
              local ch = change[2]
              scale = ChordUtil.getScaleForChord(ch)
              self:set_chord(ch)
              state.track_1_chord = ch
            end
          end
        end
      end
    end,
    follow = function(self, state)
      current_root = self:get_root_note()
      current_octave = ChordUtil.getOctaveOfRoot(current_root)
      new_root = state.track_1_root
      new_octave = ChordUtil.getOctaveOfRoot(new_root)
      octave_diff = current_octave - new_octave
      
      if self:get_chord() > 2 and state.tracks[1]:get_chord() > 2 then
        ct = state.track_1_chord
        self:set_chord(ct)
        scale = ChordUtil.getScaleForChord(ct)
      end

      n = new_root + (12 * octave_diff)
      self:set_root_note(n)
    end,
    get_notes = function(self, state)
      if state.globals.get_follow_state() == 1 and self:get_chord() > 1 and self.title ~= 'track 1' then
        self:follow(state)
      end
      
      r = self:get_root_note()
      c = self:get_chord() -- diatonic chord
      t = self:get_play_mode() -- playback mode (arp up, arp down, arp random, chord)
      scale = ChordUtil.getScaleForChord(c)
      
      if c == 1 then -- return fixed root note
        return r
      end
      
      -- calculate note offsets from root
      offsets = ChordUtil.getOffsetsForChord(c)
      -- calculate MIDI note numbers
      notes = ChordUtil.getNotesforOffsets(offsets)

      self:set_arp_position(#notes, t) -- increment/decrement/randomize or reset arp
      current_arp_position = self:get_arp_position()
      
      -- get shift position and value
      op = self:get_octave_position()
      op_multiple = self:get_shift_step_multiple(op)
      op_degree = self:get_shift_step_degree(op)
      
      if op_multiple == nil or op_degree == nil or op_multiple == 0 then
        if t == 4 then -- chord
          return notes
        else -- arp
          if c > 2 then
            return notes[current_arp_position]
          else
            return r
          end
        end
      else 
        if t == 4 then -- calculate inversion for chord
          return ChordUtil.getInversionForChord(notes, op_multiple)
        else -- calculate shift for note
          if c == 2 then -- calculate root note + shift
            return self.shift_note(r, op_degree, op_multiple)
          else -- calculate arp position + shift
            return self.shift_arpeggio_note(scale, offsets, current_arp_position, op_degree, op_multiple, r)
          end
        end
      end
    end,
    shift_note = function(r, op_degree, op_multiple)
      shift = (op_degree - 1) * op_multiple
      return r + shift
    end,
    shift_arpeggio_note = function(scale, offsets, current_arp_position, op_degree, op_multiple, r)
      index = 0
      for i = 1, #scale do
        if scale[i] == offsets[current_arp_position] then
          index = i
          break
        end
      end
      shift = (op_degree - 1) * op_multiple
      if index + shift <= #scale and index + shift > 0 then -- ensure shifted value is not outside of 0 - 127 MIDI note range
        return scale[index + shift] + r
      else
        return scale[index] + r
      end
    end,
    get_fixed_velocity = function(self)
      return self.paramSets[velocityParams].values[fixedVelocity]
    end,
    set_fixed_velocity = function(self, number)
      self.paramSets[velocityParams].values[fixedVelocity] = number
    end,
    get_max_velocity = function(self)
      return self.paramSets[velocityParams].values[maxVelocity]
    end,
    set_max_velocity = function(self, number)
      self.paramSets[velocityParams].values[maxVelocity] = number
    end,
    get_velocity_randomization = function(self)
      return self.paramSets[velocityParams].values[velocityRandomization]
    end,
    set_velocity_randomization = function(self, number)
      self.paramSets[velocityParams].values[velocityRandomization] = number
    end
  }, self)
end

Track.divisions = {
  { displayValue = '1/', value = 4 }, -- whole
  { displayValue = '/2', value = 2 }, -- half
  { displayValue = '/4', value = 1 }, -- quarter
  { displayValue = '/8', value = 0.5 }, -- eighth
  { displayValue = '/16', value = 0.25 }, -- sixteenth
  -- { displayValue = '/32', value = 0.125 } -- thirty-second
}

Track.shift_presets = {
  { 2, 1, 0, -1, -2, -1, 0, 1, 2, 1, 0, -1, -2, -1, 0, 1 },
  { 2, 0, -2, 0, 2, 0, -2, 0, 2, 0, -2, 0, 2, 0, -2, 0 },
  { 0, 1, 2, 2, 1, 0, -1, -2, -2, -1, 0, 1, 2, 2, 1, 0 }
}

Track.msg_type = {
  'note',
  'cc'
}

-- Track.create(title, start_channel, end_channel, start_output, end_output, msg_type)
-- set start/end channel apart for channel shift register
-- set start/end output apart for midi output shift register
-- set msg_type to 1 for note output, 2 for cc output
local track1 = Track:create('track 1', 1, 1, 1, 1, 1)
local track2 = Track:create('track 2', 2, 2, 1, 1, 1)
local track3 = Track:create('track 3', 3, 3, 1, 1, 1)
local track4 = Track:create('track 4', 4, 4, 1, 1, 1)

local Tracks = {
  track1,
  track2,
  track3,
  track4
}

function Tracks.reset(reset)
  clock.sync(1)
  for i = 1, #Tracks do
    Tracks[i]:set_position(1)
    Tracks[i]:set_octave_position(1)
    Tracks[i]:set_arp_position(1)
  end
  clock.cancel(reset)
  reset = 0
end

return Tracks