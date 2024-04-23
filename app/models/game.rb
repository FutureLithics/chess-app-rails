# frozen_string_literal: true

class Game < ApplicationRecord
  enum :player_turn, %i[white_turn black_turn]

  after_create :initialize_game, unless: :skip_callbacks

  has_many :pieces
  has_many :turns

  scope :active_game_by_user, ->(user) { where(player_one: user).or(where(player_two: user)) }

  def get_active_pieces
    pieces.where(active: true)
  end

  def get_active_pieces_by_color(color)
    pieces.where(active: true, color: color)
  end

  def get_player_by_turn
    white_turn? ? player_one : player_two
  end

  def cpu_move
    color = white_turn? ? 'white' : 'black'

    cpu_pieces = get_active_pieces_by_color(color)
    pieces = get_active_pieces

    ChessService.cpu_move(pieces, cpu_pieces)

    puts 'Hey!'
  end

  private

  def initialize_game
    ChessService.new(self)
  end
end
