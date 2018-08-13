require 'rails_helper'

RSpec.describe Bowling, type: :model do
  let(:bowling) { Bowling.create }
  before(:each) { Rails.cache.clear }

  context "bowling model intialization" do
    let(:bowling) { Bowling.create }

    it "should contain initial frames and point" do
      expect(Bowling.create.frames).to eq [[]]
      expect(Bowling.create.score).to eq 0
    end

    it "should contain pins_number and frames_number" do
      expect(Bowling::PINS_NUMBER).to eq 10
      expect(Bowling::FRAMES_NUMBER).to eq 10
    end

    it "should cache find_by_id" do
      expect(Bowling).to receive(:find).and_call_original
      Bowling.cached_id bowling.id

      expect(Bowling).not_to receive(:find).and_call_original
      Bowling.cached_id bowling.id
    end
  end

  context "Available pins" do

    context "normal situation of the frame" do
      it "should fall only available pins" do
        expect { bowling.bowl_throw fallen_pins: 13 }.to raise_error Errors::FreePinsError
        expect { bowling.bowl_throw fallen_pins: -3 }.to raise_error Errors::FreePinsError
      end

      it "should raise error message when try over number of pins" do
        bowling.bowl_throw fallen_pins: 6
        expect { bowling.bowl_throw fallen_pins: 5 }.to raise_error Errors::FreePinsError
      end
    end

    context "last frame" do
      before :each do
        9.times do
          bowling.bowl_throw fallen_pins: 3
          bowling.bowl_throw fallen_pins: 5
        end
      end

      it "should raise error mesage if try to fall more then available pins" do
        expect(bowling.score).to eq 72
        bowling.bowl_throw fallen_pins: 3
        expect { bowling.bowl_throw fallen_pins: 8 }.to raise_error Errors::FreePinsError
      end

      it "should raise error mesage if try to fall more then available pins after strike" do
        expect(bowling.score).to eq 72
        bowling.bowl_throw fallen_pins: 10

        expect { bowling.bowl_throw fallen_pins: 11 }.to raise_error Errors::FreePinsError
        bowling.bowl_throw fallen_pins: 5
        expect { bowling.bowl_throw fallen_pins: 6 }.to raise_error Errors::FreePinsError
        bowling.bowl_throw fallen_pins: 5
        expect(bowling.score).to eq 92

        expect { bowling.bowl_throw fallen_pins: 1 }.to raise_error Errors::OverBowlingError
      end


      it "should raise error mesage if try to fall more then available pins after a spare" do
        expect(bowling.score).to eq 72
        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 5

        expect { bowling.bowl_throw fallen_pins: 11 }.to raise_error Errors::FreePinsError
        bowling.bowl_throw fallen_pins: 5
        expect(bowling.score).to eq 87

        expect { bowling.bowl_throw fallen_pins: 1 }.to raise_error Errors::OverBowlingError
      end
    end
  end

  context "single frame" do
    it "should display correct point" do
      bowling.bowl_throw fallen_pins: 4
      expect(bowling.score).to eq 4
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 7
      expect(bowling.frames).to eq [[4,3], []]
    end
  end

  context "multiple bowling game" do
    it "should display accurate score" do
      bowling.bowl_throw fallen_pins: 4
      bowling.bowl_throw fallen_pins: 3

      bowling.bowl_throw fallen_pins: 4
      expect(bowling.score).to eq 11
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 14
      expect(bowling.frames).to eq [[4,3], [4,3], []]
    end

    context "when a frame have strike" do
      it "should show accurate point" do
        bowling.bowl_throw fallen_pins: 10
        expect(bowling.score).to eq 10

        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 3
        expect(bowling.score).to eq 26
        expect(bowling.frames).to eq [[10, 5, 3], [5,3], []]
      end
    end

    context "when a frame have spare" do
      it "should show accurate point" do
        bowling.bowl_throw fallen_pins: 4
        bowling.bowl_throw fallen_pins: 6
        expect(bowling.score).to eq 10

        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 3
        expect(bowling.score).to eq 23
        expect(bowling.frames).to eq [[4, 6, 5], [5,3], []]
      end
    end
  end

  context "all frames" do
    before :each do
      9.times do
        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 3
      end
    end

    it "should raise error when try to more throws than its required" do
      bowling.bowl_throw fallen_pins: 5
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 80
      expect(bowling.frames).to eq [[5,3]]*10
      expect(bowling.game_finished?).to eq true
      expect { bowling.bowl_throw fallen_pins: 3 }.to raise_error(Errors::OverBowlingError)
    end

    it "should control last frame with strike" do
      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 82
      expect(bowling.game_finished?).to eq false

      expect { bowling.bowl_throw  fallen_pins: 3 }.not_to raise_error
      expect(bowling.score).to eq 85
      expect(bowling.game_finished?).to eq false

      expect { bowling.bowl_throw fallen_pins: 4 }.not_to raise_error
      expect(bowling.score).to eq 89
      expect(bowling.game_finished?).to eq true
      expect(bowling.frames).to eq([[5,3]]*9 << [10,3,4])
      expect { bowling.bowl_throw fallen_pins: 4 }.to raise_error(Errors::OverBowlingError)
    end

    it "should controll last frame with spare" do
      bowling.bowl_throw fallen_pins: 4
      bowling.bowl_throw fallen_pins: 6
      expect(bowling.score).to eq 82
      expect(bowling.game_finished?).to eq false

      expect { bowling.bowl_throw fallen_pins: 3 }.not_to raise_error
      expect(bowling.score).to eq 85
      expect(bowling.game_finished?).to eq true
      expect(bowling.frames).to eq([[5,3]]*9 << [4,6,3])
      expect { bowling.bowl_throw fallen_pins: 4 }.to raise_error(Errors::OverBowlingError)
    end

    it "should handle the last frame with 3 strikes" do
      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 82
      expect(bowling.game_finished?).to eq false

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 92
      expect(bowling.game_finished?).to eq false

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 102
      expect(bowling.game_finished?).to eq true
      expect(bowling.frames).to eq([[5,3]]*9 << [10,10,10])
    end
  end

  context "test with different scenarios" do
    specify "consecutive 2 strikes" do
      bowling.bowl_throw fallen_pins: 5
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 8

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 18

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 38

      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 47
      bowling.bowl_throw fallen_pins: 4
      expect(bowling.score).to eq 55
    end

    specify "consecutive spare and strike" do
      bowling.bowl_throw fallen_pins: 5
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 8

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 18

      bowling.bowl_throw fallen_pins: 2
      expect(bowling.score).to eq 22
      bowling.bowl_throw fallen_pins: 8
      expect(bowling.score).to eq 38

      bowling.bowl_throw fallen_pins: 1
      expect(bowling.score).to eq 40
      bowling.bowl_throw fallen_pins: 9
      expect(bowling.score).to eq 49

      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 55
      bowling.bowl_throw fallen_pins: 4
      expect(bowling.score).to eq 59
    end

    specify "multiple strikes in 2 different frame" do
      8.times do
        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 3
      end
      expect(bowling.score).to eq 64

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 74
      expect(bowling.game_finished?).to eq false

      bowling.bowl_throw fallen_pins: 10
      expect(bowling.score).to eq 94
      bowling.bowl_throw fallen_pins: 5
      expect(bowling.score).to eq 104
      bowling.bowl_throw fallen_pins: 3
      expect(bowling.score).to eq 107
      expect(bowling.game_finished?).to eq true
    end

    specify "last frame with spare" do
      9.times do
        bowling.bowl_throw fallen_pins: 5
        bowling.bowl_throw fallen_pins: 3
      end
      expect(bowling.score).to eq 72

      bowling.bowl_throw fallen_pins: 4
      bowling.bowl_throw fallen_pins: 6
      expect(bowling.score).to eq 82
      expect(bowling.game_finished?).to eq false

      bowling.bowl_throw fallen_pins: 7
      expect(bowling.score).to eq 89
      expect(bowling.game_finished?).to eq true
    end
  end
end
