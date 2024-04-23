# frozen_string_literal: true

class AddPlayerTurnToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :player_turn, :integer, default: 0
  end
end
