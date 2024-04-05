# frozen_string_literal: true

class PieceBase
  attr_accessor :piece, :pieces, :color

  def initialize(piece, pieces)
    @piece = piece
    @pieces = pieces
    @color = piece[:color]
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
end
