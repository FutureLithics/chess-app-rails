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
    pieces.any? { |c| c[:position_x] == x && c[:position_y] == y && c[:active] }
  end

  def get_piece_from_square(x, y)
    pieces.select { |c| c[:position_x] == x && c[:position_y] == y }.first
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
    
    parsed_elements = parse_for_virtualization(virtual_pieces, x, y)

    virtual_piece = parsed_elements[:virtual_piece]
    king = virtual_piece[:piece_type] == 'king' ? virtual_piece : parsed_elements[:king]
    enemies = parsed_elements[:enemies]

    enemies = remove_enemy_if_move_kills(enemies, x, y)

    return enemies_threaten_piece?(enemies, king, parsed_elements[:virtual_pieces]) unless king.nil?

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

  def parse_for_virtualization(virtual_pieces, x, y)
    hash = { king: nil, virtual_piece: nil, enemies: [], virtual_pieces: [] }

    virtual_pieces.each do |vp|
      virtual_piece = vp.dup
      if vp[:id] == piece[:id]
        virtual_piece[:position_x] = x
        virtual_piece[:position_y] = y

        hash[:virtual_piece] = virtual_piece
      elsif vp[:color] != piece[:color]
        hash[:enemies].push virtual_piece
      elsif vp[:color] == piece[:color] && vp[:piece_type] == 'king'
        hash[:king] = virtual_piece
      end

      hash[:virtual_pieces].push virtual_piece 
    end

    hash
  end

  def remove_enemy_if_move_kills(enemies, x, y)
    enemies.reject { |enemy| enemy[:position_x] == x && enemy[:position_y] == y }
  end
end
