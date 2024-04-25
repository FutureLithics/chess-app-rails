# frozen_string_literal: true

# Get Rooked!!!

class KingMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[1, 1], [1, -1], [-1, -1], [-1, 1], [0, 1], [1, 0], [0, -1], [-1, 0]].freeze
  SPECIAL_MOVES = [[-2, 0], [2, 0]].freeze

  def piece_with_moves
    hash = hash_piece(piece)

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
    special_moves(moves, x, y)
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

  def special_moves(moves, x, y)
    return moves if piece[:moved]

    SPECIAL_MOVES.each_with_index do |m, _i|
      next unless test_castle_moves(_i, y)

      moveX = x + m[0]
      moveY = y + m[1]

      moves.push([moveX, moveY])
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

  def test_castle_moves(index, y)
    if index.zero?
      [1, 2, 3].each do |x_pos|
        return false if is_square_occupied?(x_pos, y)
      end

      castle_rook_test(0, y)
    elsif index == 1
      [5, 6].each do |x_pos|
        return false if is_square_occupied?(x_pos, y)
      end

      castle_rook_test(7, y)
    end
  end

  def castle_rook_test(x, y)
    return false unless is_square_occupied?(x, y)

    piece = get_piece_from_square(x, y)

    return false if piece[:moved] || piece[:checked]

    true
  end
end
