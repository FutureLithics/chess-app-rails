# frozen_string_literal: true

class CreateGames < ActiveRecord::Migration[7.1]
  def change
    create_table :games do |t|
      t.integer :player_one, null: true
      t.integer :player_two, null: true
      t.integer :winner

      t.timestamps
    end

    add_foreign_key :games, :users, column: :player_one
    add_foreign_key :games, :users, column: :player_two
    add_foreign_key :games, :users, column: :winner
  end
end
