# frozen_string_literal: true

class AddGameStateToGames < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :game_state, :integer, default: 0
  end
end
