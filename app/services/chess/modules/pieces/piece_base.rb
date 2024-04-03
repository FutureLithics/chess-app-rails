# frozen_string_literal: true

class PieceBase
  attr_accessor :piece, :color

  def initialize(piece)
    @piece = piece
    @color = piece[:color]
  end
end
