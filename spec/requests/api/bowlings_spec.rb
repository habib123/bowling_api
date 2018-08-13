require 'rails_helper'

RSpec.describe "Bowlings", type: :request do
  before(:each) { Rails.cache.clear }
  let(:bowling) { Bowling.create }

  context 'schema test' do
    it 'attributes of Bowling model with show action' do
      get api_bowling_path(bowling.id.to_s)
       expect(response).to match_response_bowling_schema 'bowling'
    end
  end

  context "start new game" do
    it "start a new bowling game" do
      post api_bowlings_path
      expect(json[:id]).to eq(1)
    end
  end

  context "#show" do
    it "should display score details" do
      expect(Bowling).to receive(:find).and_call_original
      get api_bowling_path(bowling.id.to_s)
      expect(response).to have_http_status(200)
      expect(json).to eq({ id: bowling.id, point: 0, point_by_frame: [[]], game_over: false})
    end

    it "should response from cache" do
      expect(Bowling).to receive(:find).and_call_original
      get api_bowling_path(bowling.id.to_s) # store in cache

      expect(Bowling).not_to receive(:find).and_call_original
      get api_bowling_path(bowling.id)
      expect(response).to have_http_status(200)
      expect(json).to eq({id: bowling.id, "point": 0, "point_by_frame": [[]], "game_over": false})
    end
  end

  context "#update" do
    it "update the point" do
      put api_bowling_path(bowling.id, "fallen_pins": 3)
      expect(response).to have_http_status(204)
      expect(Bowling.find(bowling.id).score).to eq 3
      expect(Bowling.find(bowling.id).frames).to eq [[3]]
    end

    it "should get error if try to knock overflow pins" do
      put api_bowling_path(bowling.id, fallen_pins: 15)
      expect(json).to eq({"message": "You have less pin available."})
      expect(response).to have_http_status(422)
    end


    it "should get error if try to throw after game finished" do
      10.times do
        put api_bowling_path(bowling.id.to_s, "fallen_pins" => "3")
        put api_bowling_path(bowling.id.to_s, "fallen_pins" => "3")
      end
      expect(Bowling.find(bowling.id).frames).to eq([[3,3]]*10)

      put api_bowling_path(bowling.id, "fallen_pins" => "10")
      expect(json).to eq({"message": "The bowling game is over"})
      expect(response).to have_http_status(422)
    end

    context " Error checking and validation of params" do
      it "should show error message if param is missing" do
        put api_bowling_path(bowling.id.to_s)
        expect(json[:message]).to include("param is missing")
      end

      it "should show error message if given param is blank" do
        put api_bowling_path(bowling.id, fallen_pins: "")
        expect(json[:message]).to include("param is missing")
      end

      it "should show error message if given param is not a number" do
        put api_bowling_path(bowling.id, fallen_pins: "4de5")
        expect(json[:message]).to include("Input is not correct format")
      end
    end
  end
end
