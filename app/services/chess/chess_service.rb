# frozen_string_literal: true

class ChessService < ApplicationService
  include GameInitializer
  extend PieceMoves

  attr_accessor :game

  def initialize(game, init_pieces = true)
    @game = game

    initialize_pieces(game) if init_pieces
  end

  def self.get_available_moves(piece, pieces, deep = true)
    get_moves_by_piece(piece, pieces, deep)
  end
end
