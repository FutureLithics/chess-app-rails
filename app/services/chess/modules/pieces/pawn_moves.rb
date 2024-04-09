# frozen_string_literal: true

class PawnMoves < PieceBase
  attr_accessor :direction, :moved

  PATTERNS = [[0, 1], [0, 2], [1, 1], [-1, 1]].freeze

  def piece_with_moves
    @direction = determine_direction
    @moved = piece[:moved]

    hash = piece.serializable_hash

    moves = determine_available_moves(piece)
    moves = filter_king_moves(moves)

    hash[:available_moves] = moves
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
      moveX = x + m[0]
      moveY = y + direction * m[1]

      moves.push([moveX, moveY]) if determine_valid_move(moveX, moveY, i)
    end

    moves
  end

  def determine_valid_move(x, y, i)
    if i.zero?
      one_square_move(x, y)
    elsif i == 1 && !stops.include?(i)
      two_square_move(x, y)
    elsif i == 2
      attack_moves(x, y, false)
    elsif i == 3
      attack_moves(x, y)
    else
      false
    end
  end

  def one_square_move(x, y)
    if is_square_occupied?(x, y)
      stops.push(1) # if this square is occcupied, pawn can't move two spaces on next pattern

      false
    else
      true
    end
  end

  def two_square_move(x, y)
    if piece[:moved].nil? || piece[:moved] == false
      is_square_occupied?(x, y) ? false : true
    else
      false
    end
  end

  def attack_moves(x, y, passant = true)
    return true if en_passant_detected?(x, y, passant)

    is_square_occupied_by_enemy?(x, y) ? true : false
  end

  def en_passant_detected?(x, y, left = true)
    current_x = piece[:position_x]
    current_y = piece[:position_y]
    constant = left ? -1 : 1

    passant = en_passant_piece?(current_x + constant, current_y)

    passant && !is_square_occupied_by_enemy?(x, y) ? true : false
  end

  def en_passant_piece?(x, y)
    pieces.any? { |c| c[:position_x] == x && c[:position_y] == y && c[:color] != piece[:color] && c[:en_passant] }
  end
end
