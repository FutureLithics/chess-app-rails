# frozen_string_literal: true

class ChessService < ApplicationService
  include GameInitializer
  extend PieceMoves
  extend CpuMoves

  attr_accessor :game

  def initialize(game, init_pieces = true)
    @game = game

    initialize_pieces(game) if init_pieces
  end

  def self.get_available_moves(piece, pieces, deep = true)
    get_moves_by_piece(piece, pieces, deep)
  end

  def self.cpu_move(cpu_pieces, player_pieces)
    determine_move(cpu_pieces, player_pieces)
  end

  def self.get_available_moves_by_color(all_pieces, pieces)
    pieces.map { |piece| get_moves_by_piece(piece, all_pieces, true) }
  end
end
