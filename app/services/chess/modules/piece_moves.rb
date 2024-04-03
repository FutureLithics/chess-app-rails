# frozen_string_literal: true

module PieceMoves
  def get_moves_by_piece(piece)
    case piece[:piece_type]
    when 'pawn'
      PawnMoves.new(piece).piece_with_moves
    else
      piece
    end
  end
end
