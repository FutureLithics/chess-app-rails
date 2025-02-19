module MoveDetection
  def get_pawn_moves(piece, pieces)
    moves = []
    direction = piece[:color] == 'white' ? -1 : 1
    x, y = piece[:position_x], piece[:position_y]

    # Forward move
    new_y = y + direction
    if new_y.between?(0, 7) && !pieces.any? { |p| p[:position_x] == x && p[:position_y] == new_y }
      moves << [x, new_y]
      
      # Double move from starting position
      if !piece[:moved] && is_move_valid?(x, y + (2 * direction), piece, pieces)
        moves << [x, y + (2 * direction)]
      end
    end

    # Captures
    [[x - 1, new_y], [x + 1, new_y]].each do |capture_x, capture_y|
      next unless capture_x.between?(0, 7) && capture_y.between?(0, 7)
      
      target = pieces.find { |p| p[:position_x] == capture_x && p[:position_y] == capture_y }
      moves << [capture_x, capture_y] if target && target[:color] != piece[:color]
    end

    moves
  end

  def get_rook_moves(piece, pieces)
    moves = []
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    
    directions.each do |dx, dy|
      x, y = piece[:position_x], piece[:position_y]
      loop do
        x += dx
        y += dy
        break unless x.between?(0, 7) && y.between?(0, 7)
        
        target = pieces.find { |p| p[:position_x] == x && p[:position_y] == y }
        if target
          moves << [x, y] if target[:color] != piece[:color]
          break
        end
        moves << [x, y]
      end
    end
    
    moves
  end

  def get_knight_moves(piece, pieces)
    moves = []
    x, y = piece[:position_x], piece[:position_y]
    
    [
      [x+2, y+1], [x+2, y-1],
      [x-2, y+1], [x-2, y-1],
      [x+1, y+2], [x+1, y-2],
      [x-1, y+2], [x-1, y-2]
    ].each do |new_x, new_y|
      moves << [new_x, new_y] if is_move_valid?(new_x, new_y, piece, pieces)
    end
    
    moves
  end

  def get_bishop_moves(piece, pieces)
    moves = []
    directions = [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    
    directions.each do |dx, dy|
      x, y = piece[:position_x], piece[:position_y]
      loop do
        x += dx
        y += dy
        break unless x.between?(0, 7) && y.between?(0, 7)
        
        target = pieces.find { |p| p[:position_x] == x && p[:position_y] == y }
        if target
          moves << [x, y] if target[:color] != piece[:color]
          break
        end
        moves << [x, y]
      end
    end
    
    moves
  end

  def get_queen_moves(piece, pieces)
    get_rook_moves(piece, pieces) + get_bishop_moves(piece, pieces)
  end

  def get_king_moves(piece, pieces)
    moves = []
    x, y = piece[:position_x], piece[:position_y]
    
    [
      [x+1, y], [x-1, y],
      [x, y+1], [x, y-1],
      [x+1, y+1], [x+1, y-1],
      [x-1, y+1], [x-1, y-1]
    ].each do |new_x, new_y|
      moves << [new_x, new_y] if is_move_valid?(new_x, new_y, piece, pieces)
    end
    
    moves
  end

  private

  def is_move_valid?(x, y, piece, pieces)
    return false unless x.between?(0, 7) && y.between?(0, 7)
    
    target = pieces.find { |p| p[:position_x] == x && p[:position_y] == y }
    !target || target[:color] != piece[:color]
  end
end 