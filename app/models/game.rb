# frozen_string_literal: true

class Game < ApplicationRecord
  after_create :initialize_game

  has_many :pieces

  scope :active_game_by_user, ->(user) { where(player_one: user).or(where(player_two: user)) }

  def get_active_pieces
    pieces.where(active: true)
  end

  private

  def initialize_game
    ChessService.new(self)
  end
end
