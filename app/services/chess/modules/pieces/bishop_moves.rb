# frozen_string_literal: true

# Get Rooked!!!

class BishopMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[1, 1], [1, -1], [-1, -1], [-1, 1]].freeze

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
    # the maximum possible spaces for a piece to move is 7 before it will go off the board
    (1..7).each do |space|
      PATTERNS.each_with_index do |m, _i|
        next if stops.include? _i

        moveX = x + (m[0] * space)
        moveY = y + (m[1] * space)

        move_or_stop(moves, moveX, moveY, _i)
      end
    end

    moves
  end

  def move_or_stop(moves, x, y, i)
    determine_valid_move(x, y, i) ? moves.push([x, y]) : stops.push(i)
  end

  def determine_valid_move(x, y, i)
    # return false if will_move_expose_king?(x, y)

    return false if is_out_of_bounds?(x, y)

    return true unless is_square_occupied?(x, y) # in this case will be a friendly piece

    stops.push(i)

    is_square_occupied_by_enemy?(x, y) ? true : false
  end
end
