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

  def self.cpu_move(pieces, cpu_pieces)
    pieces_with_moves = get_available_moves_by_color(pieces, cpu_pieces)

    random_move(pieces_with_moves)
  end

  def self.get_available_moves_by_color(pieces, cpu_pieces)
    cpu_pieces.map { |piece| get_moves_by_piece(piece, pieces, true) }
  end
end
