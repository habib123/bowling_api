class Api::BowlingsController < Api::ApiController
  skip_before_action :verify_authenticity_token

  def create
    json_response({id: start_game.id}, :created)
  end

  def show
    json_response(bowling_hash, :ok)
  end

  def update
    bowling.check_char? params[:fallen_pins]
    bowling.bowl_throw fallen_pins: update_params[:fallen_pins].to_i
    json_response({}, :no_content)
  rescue => e
    json_response({message: e.message}, :unprocessable_entity)
  end

private

  def start_game
    @start_game ||= Bowling.create!
  end

  def bowling
    @bowling ||= Bowling.cached_id(params[:id])
  end

  def update_params
    params.require(:fallen_pins)
    params.permit(:fallen_pins)
  end

  def bowling_hash
    {
      id: bowling.id,
      point: bowling.score,
      point_by_frame: bowling.frames,
      game_over: bowling.game_finished?,
    }
  end
end
