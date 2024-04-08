# frozen_string_literal: true

module PieceMoves
  def get_moves_by_piece(piece, pieces)
    case piece[:piece_type]
    when 'pawn'
      PawnMoves.new(piece, pieces).piece_with_moves
    when 'knight'
      KnightMoves.new(piece, pieces).piece_with_moves
    when 'rook'
      RookMoves.new(piece, pieces).piece_with_moves
    when 'bishop'
      BishopMoves.new(piece, pieces).piece_with_moves
    when 'queen'
      QueenMoves.new(piece, pieces).piece_with_moves
    when 'king'
      KingMoves.new(piece, pieces).piece_with_moves
    else
      piece
    end
  end
end
