# frozen_string_literal: true

class Turn < ApplicationRecord
  belongs_to :game

  def get_first_position
    [initial_x, initial_y]
  end

  def get_second_position
    [next_x, next_y]
  end
end
