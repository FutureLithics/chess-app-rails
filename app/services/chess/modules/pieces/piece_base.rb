# frozen_string_literal: true

class PieceBase
  attr_accessor :piece, :pieces, :color

  def initialize(piece, pieces)
    @piece = piece
    @pieces = pieces
    @color = piece[:color]
  end
end
