class Bowling < ActiveRecord::Base
  include CacheRecords
  include Errors

  PINS_NUMBER = 10
  FRAMES_NUMBER = 10

  before_save :initialize_score
  serialize :frames, Array

  def bowl_throw fallen_pins:
    self.transaction do
      self.lock!
      raise Errors::OverBowlingError if game_finished?
      raise Errors::FreePinsError unless fallen_pins.between?(0, pins_availability)
      frames.last << fallen_pins
      add_point_with_previous_frames fallen_pins
      frames << [] if frame_finished?(frames.last) && game_finished?.!
      save!
    end
  end

  def game_finished?
    frames.size==FRAMES_NUMBER && frame_finished?(frames.last)
  end

  def initialize_score
    self.frames = [[]] if frames.empty?
    self.score = frames.flatten.sum
    self.delete_from_cache
  end

  def check_char?(fallen_pins)
    raise Errors::IvalidParameter  if fallen_pins.to_s.chars.any? {|c| c=~/[^\d]/}
  end

private

  def add_point_with_previous_frames score
    frames.map do |f |
      next if f.equal?(frames.last)
      f << score if  frame_size f
    end
  end

  def frame_size f
    return true if (check_spare?(f) && f.size == 2) || (check_strike?(f) && f.size <= 2)
    false
  end

  def check_strike? frame
    frame[0] == PINS_NUMBER
  end

  def double_check_strike? frame
    frame[0] == PINS_NUMBER && frame[1] == PINS_NUMBER
  end

  def check_spare? frame
    [frame[0],frame[1]].compact.sum == PINS_NUMBER
  end

  def last_frame? frame
    frames.size==FRAMES_NUMBER && frames.last.equal?(frame)
  end

  def frame_finished? frame
    return last_frame_finished?(frame) if last_frame?(frame)
    return true if check_strike?(frame) || frame.size==2 || frame.nil?
    false
  end

  def last_frame_finished? frame
    if (check_strike?(frame) || check_spare?(frame))
      frame.size == 3
    else
      frame.size == 2
    end
  end

  def pins_availability
    present_frame = frames.last
    present_frame_score = present_frame.to_a.sum
    if last_frame?(present_frame)
      return (PINS_NUMBER*3 - present_frame_score) if double_check_strike?(present_frame)
      return (PINS_NUMBER*2 - present_frame_score) if check_strike?(present_frame) || check_spare?(present_frame)
    end
    PINS_NUMBER - present_frame_score
  end
end
