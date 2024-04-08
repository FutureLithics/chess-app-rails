# frozen_string_literal: true

# Get Rooked!!!

class KingMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[1, 1], [1, -1], [-1, -1], [-1, 1], [0, 1], [1, 0], [0, -1], [-1, 0]].freeze

  def piece_with_moves
    hash = piece.serializable_hash
    hash[:available_moves] = determine_available_moves(piece)
    hash.symbolize_keys
  end

  def determine_available_moves(piece)
    x = piece[:position_x].to_i
    y = piece[:position_y].to_i

    moves = []

    basic_moves(moves, x, y)
  end

  def basic_moves(moves, x, y)
    PATTERNS.each_with_index do |m, _i|
      next if stops.include? _i

      moveX = x + m[0]
      moveY = y + m[1]

      move_or_stop(moves, moveX, moveY, _i)
    end

    moves
  end

  def move_or_stop(moves, x, y, i)
    determine_valid_move(x, y, i) ? moves.push([x, y]) : stops.push(i)
  end

  def determine_valid_move(x, y, i)
    return false if is_out_of_bounds?(x, y)

    return true unless is_square_occupied?(x, y) # in this case will be a friendly piece

    stops.push(i)

    is_square_occupied_by_enemy?(x, y) ? true : false
  end
end
