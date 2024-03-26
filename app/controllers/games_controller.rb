# frozen_string_literal: true

class GamesController < ApplicationController
  def index; end

  def new
    @game = Game.new
    @opponents = User.computer_opponents
  end

  def show; end

  def create
    opponent = game_params[:player_two]

    game = Game.new(player_one: current_user, player_two: opponent)

    if game.save
      # create presenter for sending up game data
      @presenter = BoardPresenter.new(game)

      puts @presenter

      respond_to do |format|
        format.html { redirect_to game_room_path }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update; end

  def destroy; end

  private

  def game_params
    params.require(:game).permit(:player_two)
  end
end
