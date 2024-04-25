# frozen_string_literal: true

class Game < ApplicationRecord
  enum :player_turn, %i[white_turn black_turn]
  enum :game_state, %i[in_progress checkmate stalemate resigned abandoned]

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

  def set_checkmate(color)
    checkmate!

    winner = if color == 'white'
               player_two
             else
               player_one
             end

    update!(winner: winner)
  end

  def cpu_move
    color = white_turn? ? 'white' : 'black'

    cpu_pieces = get_active_pieces_by_color(color)
    all_pieces = get_active_pieces
    player_pieces = all_pieces - cpu_pieces

    cpu_pieces = ChessService.get_available_moves_by_color(all_pieces, cpu_pieces)
    player_pieces = ChessService.get_available_moves_by_color(all_pieces, player_pieces)

    ChessService.cpu_move(cpu_pieces, player_pieces)
  end

  private

  def initialize_game
    ChessService.new(self)
  end
end
