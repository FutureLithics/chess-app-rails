# frozen_string_literal: true

class Turn < ApplicationRecord
  include LogHelper
  belongs_to :game

  validates :game_id, :player_id, :initial_x, :initial_y, :next_x, :next_y, presence: true

  after_create :update_game_player

  after_initialize do
    Rails.logger.debug cpu_log("🎲 Turn initialized with:")
    Rails.logger.debug cpu_log("  Game ID: #{game_id}")
    Rails.logger.debug cpu_log("  Player ID: #{player_id}")
    Rails.logger.debug cpu_log("  Move: (#{initial_x},#{initial_y}) -> (#{next_x},#{next_y})")
  end

  def get_first_position
    [initial_x, initial_y]
  end

  def get_second_position
    [next_x, next_y]
  end

  private

  def update_game_player
    Rails.logger.debug cpu_log("⚡ TURN CALLBACK - Player: #{player_id}")
    
    current_player = game.get_player_by_turn
    
    unless player_id == current_player
      Rails.logger.error error_log("❌ Move made by wrong player!")
      return
    end

    game.toggle_turn!
    game.reload

    if game.get_player_by_turn == game.player_two && game.player_two_user&.cpu?
      Rails.logger.debug cpu_log("🤖 CPU's turn - initiating move")
      move_result = game.cpu_move
      
      if move_result
        Rails.logger.debug success_log("✅ CPU move successful")
      else
        Rails.logger.error error_log("❌ CPU move failed")
      end
    end
  end
end
