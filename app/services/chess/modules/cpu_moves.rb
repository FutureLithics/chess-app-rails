# frozen_string_literal: true

module CpuMoves
  def random_move(pieces)
    moves = create_moves_ranking(pieces)

    move = moves.sample

    update_piece(move)
  end

  def update_piece(move)
    piece = Piece.find_by_id(move[:id])

    piece.update!(position_x: move[:position][0], position_y: move[:position][1])
  end

  def create_moves_ranking(pieces)
    moves = []

    pieces.each do |piece|
      piece[:available_moves].map do |move|
        hash = {
          id: piece[:id],
          color: piece[:color],
          position: move,
          rating: 0
        }

        moves.push hash
      end
    end

    moves
  end
end
