# frozen_string_literal: true

class CreateTurns < ActiveRecord::Migration[7.1]
  def change
    create_table :turns do |t|
      t.integer :game_id, null: false
      t.integer :player_id, null: true
      t.integer :initial_x, null: false
      t.integer :initial_y, null: false
      t.integer :next_x, null: false
      t.integer :next_y, null: false

      t.timestamps
    end
  end
end
