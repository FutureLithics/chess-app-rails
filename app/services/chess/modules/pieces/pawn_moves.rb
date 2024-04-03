# frozen_string_literal: true

class PawnMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[0, 1], [0, 2], [1, 1], [-1, 1]].freeze

  def piece_with_moves
    piece
    @direction = determine_direction
    @moved = piece[:moved]

    hash = piece.serializable_hash
    hash[:available_moves] = determine_available_moves(piece)

    hash.symbolize_keys
  end

  def determine_direction
    # if true, then we move in negative y direction
    piece[:color] == 'white' ? -1 : 1
  end

  def determine_available_moves(piece)
    x = piece[:position_x].to_i
    y = piece[:position_y].to_i

    moves = []

    basic_moves(moves, x, y)
  end

  def basic_moves(moves, x, y)
    PATTERNS.each_with_index do |m, i|
      moves.push([x + m[0], y + direction * m[1]]) if i < 2
    end

    moves
  end
end
