# frozen_string_literal: true

class KnightMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[-1, 2], [1, 2], [2, 1], [-2, 1], [-1, -2], [1, -2], [2, -1], [-2, -1]].freeze

  def piece_with_moves
    hash = piece.serializable_hash

    moves = determine_available_moves(piece)
    moves = filter_king_moves(moves)

    hash[:available_moves] = moves
    hash.symbolize_keys
  end

  def determine_available_moves(piece)
    x = piece[:position_x].to_i
    y = piece[:position_y].to_i

    moves = []

    basic_moves(moves, x, y)
  end

  def basic_moves(moves, x, y)
    # return false if will_move_expose_king?(x, y)

    PATTERNS.each_with_index do |m, _i|
      moveX = x + m[0]
      moveY = y + m[1]

      moves.push([moveX, moveY]) if determine_valid_move(moveX, moveY)
    end

    moves
  end

  def determine_valid_move(x, y)
    return false if is_out_of_bounds?(x, y)

    return is_square_occupied_by_enemy?(x, y) if is_square_occupied?(x, y) # in this case will be a friendly piece

    true
  end
end
