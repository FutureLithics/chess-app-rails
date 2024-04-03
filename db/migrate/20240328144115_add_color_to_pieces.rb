# frozen_string_literal: true

class AddColorToPieces < ActiveRecord::Migration[7.1]
  def change
    add_column :pieces, :color, :string
  end
end
