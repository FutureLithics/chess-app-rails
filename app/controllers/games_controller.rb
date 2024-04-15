# frozen_string_literal: true

class GamesController < ApplicationController
  helper_method :current_or_guest_user

  def index; end

  def new
    @game = Game.new
    @opponents = User.computer_opponents
  end

  def show
    game = Game.active_game_by_user(current_or_guest_user).last
    @user = current_or_guest_user

    @presenter = BoardPresenter.new(current_or_guest_user, game)
  end

  def create
    opponent = game_params[:player_two]

    game = Game.new(player_one: current_or_guest_user.id, player_two: opponent)

    if game.save
      # create presenter for sending up game data
      @presenter = BoardPresenter.new(current_or_guest_user, game)
      @user = current_or_guest_user

      respond_to do |format|
        format.html { redirect_to game_room_path }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def move
    piece = Piece.find_by_id(move_params[:piece_id])
    x = move_params[:position_x]
    y = move_params[:position_y]

    valid_move = piece.update(position_x: x, position_y: y)

    if valid_move
		game = Game.find_by_id(piece[:game_id])
		presenter = BoardPresenter.new(current_or_guest_user, game)

		piece.broadcast_update_to(:move_updates, partial: 'games/partials/board', target: 'chess_board',
			locals: { presenter: presenter, user: current_or_guest_user })
      respond_to do |format|
        format.json { render json: { success: true } }
      end
    else
      flash.alert = 'Move Invalid'
    end
  end

  def update; end

  def destroy; end

  private

  def game_params
    params.require(:game).permit(:player_two)
  end

  def move_params
    params.require(:move).permit(:piece_id, :position_x, :position_y)
  end
end
