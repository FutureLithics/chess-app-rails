# frozen_string_literal: true

class Game < ApplicationRecord
  after_create :initialize_game

  has_many :pieces

  def get_active_pieces
    pieces(&:active)
  end

  private

  def initialize_game
    ChessService.new(self)
  end
end
