# frozen_string_literal: true

module PieceMoves
  def get_moves_by_piece(piece, pieces)
    case piece[:piece_type]
    when 'pawn'
      PawnMoves.new(piece, pieces).piece_with_moves
    else
      piece
    end
  end
end
