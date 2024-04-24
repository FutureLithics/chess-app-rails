# frozen_string_literal: true

class AddRatingToPieces < ActiveRecord::Migration[7.1]
  def change
    add_column :pieces, :rating, :integer, default: 1
  end
end
