# frozen_string_literal: true

module PieceMoves
  def get_moves_by_piece(piece, pieces, deep = true)
    case piece[:piece_type].to_s.downcase
    when 'pawn'
      get_pawn_moves(piece, pieces)
    when 'knight'
      get_knight_moves(piece, pieces)
    when 'bishop'
      get_bishop_moves(piece, pieces)
    when 'rook'
      get_rook_moves(piece, pieces)
    when 'queen'
      get_queen_moves(piece, pieces)
    when 'king'
      get_king_moves(piece, pieces)
    else
      []
    end
  end

  def get_pawn_moves(piece, pieces)
    moves = []
    x = piece[:position_x]
    y = piece[:position_y]
    direction = piece[:color] == 'white' ? -1 : 1

    # Forward move
    forward = [x, y + direction]
    moves << forward if valid_position?(forward) && !piece_at?(pieces, forward)

    # Initial two-square move
    if !piece[:moved]
      double_forward = [x, y + (2 * direction)]
      if valid_position?(double_forward) && !piece_at?(pieces, forward) && !piece_at?(pieces, double_forward)
        moves << double_forward
      end
    end

    # Captures
    [[x - 1, y + direction], [x + 1, y + direction]].each do |pos|
      next unless valid_position?(pos)
      target = piece_at?(pieces, pos)
      moves << pos if target && target[:color] != piece[:color]
    end

    moves
  end

  def get_rook_moves(piece, pieces)
    get_sliding_moves(piece, pieces, [[0, 1], [0, -1], [1, 0], [-1, 0]])
  end

  def get_knight_moves(piece, pieces)
    moves = []
    x = piece[:position_x]
    y = piece[:position_y]
    
    [[-2, -1], [-2, 1], [-1, -2], [-1, 2],
     [1, -2], [1, 2], [2, -1], [2, 1]].each do |dx, dy|
      pos = [x + dx, y + dy]
      next unless valid_position?(pos)
      target = piece_at?(pieces, pos)
      moves << pos if !target || target[:color] != piece[:color]
    end

    moves
  end

  def get_bishop_moves(piece, pieces)
    get_sliding_moves(piece, pieces, [[1, 1], [1, -1], [-1, 1], [-1, -1]])
  end

  def get_queen_moves(piece, pieces)
    get_sliding_moves(piece, pieces, [[0, 1], [0, -1], [1, 0], [-1, 0],
                                    [1, 1], [1, -1], [-1, 1], [-1, -1]])
  end

  def get_king_moves(piece, pieces)
    moves = []
    x = piece[:position_x]
    y = piece[:position_y]
    
    [[-1, -1], [-1, 0], [-1, 1],
     [0, -1],           [0, 1],
     [1, -1],  [1, 0],  [1, 1]].each do |dx, dy|
      pos = [x + dx, y + dy]
      next unless valid_position?(pos)
      target = piece_at?(pieces, pos)
      moves << pos if !target || target[:color] != piece[:color]
    end

    moves
  end

  private

  def get_sliding_moves(piece, pieces, directions)
    moves = []
    x = piece[:position_x]
    y = piece[:position_y]

    directions.each do |dx, dy|
      current_x = x + dx
      current_y = y + dy

      while valid_position?([current_x, current_y])
        pos = [current_x, current_y]
        target = piece_at?(pieces, pos)
        
        if target
          moves << pos if target[:color] != piece[:color]
          break
        end
        
        moves << pos
        current_x += dx
        current_y += dy
      end
    end

    moves
  end

  def valid_position?(pos)
    x, y = pos
    x.between?(0, 7) && y.between?(0, 7)
  end

  def piece_at?(pieces, pos)
    x, y = pos
    pieces.find { |p| p[:position_x] == x && p[:position_y] == y }
  end
end
