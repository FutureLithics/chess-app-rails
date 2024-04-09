# frozen_string_literal: true

class PieceBase
  attr_accessor :piece, :pieces, :color, :stops, :deep

  def initialize(piece, pieces, deep)
    @piece = piece
    @pieces = pieces
    @color = piece[:color]
    @stops = []
    @deep = deep
  end

  def is_square_occupied?(x, y)
    pieces.any? { |c| c[:position_x] == x && c[:position_y] == y }
  end

  def is_square_occupied_by_enemy?(x, y)
    pieces.any? { |c| c[:position_x] == x && c[:position_y] == y && c[:color] != piece[:color] }
  end

  def is_out_of_bounds?(x, y)
    x.negative? || x > 7 || y.negative? || y > 7
  end

  def filter_king_moves(moves)
    return moves unless deep

    moves.reject do |move|
      will_move_expose_king?(move[0], move[1])
    end
  end

  def will_move_expose_king?(x, y)
    return false unless deep

    virtual_pieces = pieces
    parsed_elements = parse_for_virtualization(virtual_pieces)

    king = parsed_elements[:king]
    enemies = parsed_elements[:enemies]

    parsed_elements[:virtual_piece][position_x: x]
    parsed_elements[:virtual_piece][position_y: y]

    return enemies_threaten_piece?(enemies, king, virtual_pieces) unless king.nil?

    false
  end

  def enemies_threaten_piece?(enemies, piece_checked, virtual_pieces)
    coordinates = [piece_checked[:position_x], piece_checked[:position_y]]

    enemies.each do |enemy|
      enemy_with_moves = ChessService.get_available_moves(enemy, virtual_pieces, false)

      return true if enemy_with_moves[:available_moves].include?(coordinates)
    end

    false
  end

  def parse_for_virtualization(virtual_pieces)
    hash = { king: nil, virtual_piece: nil, enemies: [] }

    virtual_pieces.each do |vp|
      if vp[:id] == piece[:id]
        hash[:virtual_piece] = vp
      elsif vp[:color] != piece[:color]
        hash[:enemies].push vp
      elsif vp[:color] == piece[:color] && vp[:piece_type] == 'king'
        hash[:king] = vp
      end
    end

    hash
  end
end
