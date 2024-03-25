class CreatePieces < ActiveRecord::Migration[7.1]
  def change
    create_table :pieces do |t|
      t.integer :game_id
      t.integer :player_id
      t.string :name, default: "Sir Robin"
      t.string :type, null: false, default: 'pawn'
      t.integer :position_x
      t.integer :position_y
      t.boolean :checked
      t.boolean :active
      t.boolean :moved
      t.boolean :en_passant

      t.timestamps
    end
  end
end
