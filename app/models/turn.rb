# frozen_string_literal: true

class Turn < ApplicationRecord
  belongs_to :game

  after_create :update_game_player

  def get_first_position
    [initial_x, initial_y]
  end

  def get_second_position
    [next_x, next_y]
  end

  private

  def update_game_player
    game.white_turn? ? game.black_turn! : game.white_turn!

    computer_move
  end

  def computer_move
    player = User.find_by_id game.get_player_by_turn

    game.cpu_move if player.cpu?
  end
end
