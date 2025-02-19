# frozen_string_literal: true

module CpuMoves
  include LogHelper

  PIECE_VALUES = {
    pawn: 1,
    knight: 3,
    bishop: 3,
    rook: 5,
    queen: 9,
    king: 0  # Special handling for king
  }.freeze

  CENTER_SQUARES = [[3,3], [3,4], [4,3], [4,4]].freeze
  EXTENDED_CENTER = [[2,2], [2,3], [2,4], [2,5], 
                     [3,2], [3,3], [3,4], [3,5],
                     [4,2], [4,3], [4,4], [4,5],
                     [5,2], [5,3], [5,4], [5,5]].freeze

  def determine_move(cpu_pieces, player_pieces)
    Rails.logger.debug cpu_log("🎲 DETERMINE MOVE STARTED")
    Rails.logger.debug cpu_log("CPU has #{cpu_pieces.length} pieces with moves")

    # Log each piece and its moves
    cpu_pieces.each do |piece|
      Rails.logger.debug cpu_log("  • #{piece[:piece_type]} at (#{piece[:position_x]},#{piece[:position_y]}) has #{piece[:available_moves]&.length || 0} moves")
    end

    all_pieces = (cpu_pieces + player_pieces)
    game_phase = determine_game_phase(all_pieces)

    # Try opening book moves first
    Rails.logger.debug cpu_log("📚 Checking opening book")
    if game_phase == :opening
      opening_move = get_opening_move(cpu_pieces, all_pieces)
      if opening_move && valid_position?(opening_move[:position])
        Rails.logger.debug cpu_log("📖 Found opening book move")
        return opening_move
      end
    end

    # Rate all possible moves
    Rails.logger.debug cpu_log("⚖️ Rating all possible moves")
    moves = create_moves_rating(cpu_pieces, player_pieces)
    
    if moves.empty?
      Rails.logger.error error_log("❌ No valid moves found")
      return nil
    end

    # Filter out invalid moves
    valid_moves = moves.select { |m| valid_position?(m[:position]) }
    if valid_moves.empty?
      Rails.logger.error error_log("❌ No valid moves after position check")
      return nil
    end

    # Sort moves by preliminary evaluation for better pruning
    valid_moves = sort_moves_by_priority(valid_moves, all_pieces, game_phase)
    best_move = valid_moves.max_by { |m| m[:rating] }
    
    if best_move
      Rails.logger.debug cpu_log("🎯 Selected move: #{best_move[:piece_type]} with rating #{best_move[:rating]}")
      Rails.logger.debug cpu_log("  From: (#{best_move[:from_x]},#{best_move[:from_y]}) To: (#{best_move[:position].join(',')})")
    else
      Rails.logger.error error_log("❌ Could not find best move from valid moves")
    end
    
    best_move
  end

  def update_piece(move)
    Rails.logger.debug "Updating piece with move: #{move.inspect}"
    return unless move && move[:id] && move[:position]

    piece = Piece.find_by_id(move[:id])
    return unless piece

    Rails.logger.debug "Found piece: #{piece.inspect}"
    new_x, new_y = move[:position]

    begin
      result = piece.update!(
        position_x: new_x,
        position_y: new_y,
        moved: true
      )
      Rails.logger.debug "Update result: #{result}"
      result
    rescue => e
      Rails.logger.error "Failed to update piece: #{e.message}"
      false
    end
  end

  def create_moves_rating(cpu_pieces, player_pieces)
    Rails.logger.debug cpu_log("📊 Creating moves rating")
    moves = []
    all_pieces = (cpu_pieces + player_pieces).dup

    cpu_pieces.each do |piece|
      next unless piece[:available_moves]
      Rails.logger.debug cpu_log("🔍 Rating moves for #{piece[:piece_type]} at (#{piece[:position_x]},#{piece[:position_y]})")
      
      rating = determine_initial_rating(piece, player_pieces)

      piece[:available_moves].each do |move|
        next if move[0].negative? || move[0] > 7 || move[1].negative? || move[1] > 7
        
        virtual_piece = piece.dup
        rating = determine_move_rating(virtual_piece, move, all_pieces, rating)

        moves.push({
          id: piece[:id],
          piece_type: piece[:piece_type],
          color: piece[:color],
          position: move,
          from_x: piece[:position_x],
          from_y: piece[:position_y],
          rating: rating
        })
        
        Rails.logger.debug move_log("Move to (#{move.join(',')}) rated: #{rating}")
      end
    end

    Rails.logger.debug cpu_log("✨ Generated #{moves.length} rated moves")
    moves
  end

  def determine_initial_rating(piece, player_pieces)
    coordinates = [piece[:position_x], piece[:position_y]]

    return 0 unless player_pieces.any? { |p_piece| p_piece[:available_moves].include? coordinates }

    piece[:rating]
  end

  def determine_move_rating(piece, move, all_pieces, rating, current = 0, depth = 5)
    return 0 if current > depth

    # Base position value
    position_value = evaluate_position(piece, move)
    
    # Material value (capturing pieces)
    target_piece = attack_opposing_piece(move, all_pieces)
    material_value = target_piece ? PIECE_VALUES[target_piece[:piece_type].to_sym] : 0
    
    # Update piece position for further evaluation
    original_x, original_y = piece[:position_x], piece[:position_y]
    piece[:position_x], piece[:position_y] = move[0], move[1]
    
    # Calculate tactical value
    tactical_value = check_virtual_payoffs(all_pieces, rating, piece[:color], current, depth)
    
    # Restore original position
    piece[:position_x], piece[:position_y] = original_x, original_y
    
    position_value + material_value + tactical_value
  end

  def check_virtual_payoffs(all_pieces, rating, color, current, depth)
    friendly_pieces = all_pieces.select { |piece| piece[:color] == color }
    enemy_pieces = all_pieces - friendly_pieces

    friendly_pieces = ChessService.get_available_moves_by_color(all_pieces, friendly_pieces)
    enemy_pieces = ChessService.get_available_moves_by_color(all_pieces, enemy_pieces)

    friendly_payoff = calculate_payoff(friendly_pieces, enemy_pieces, current, depth)
    enemy_payoff = calculate_payoff(enemy_pieces, friendly_pieces, current, depth)

    rating + friendly_payoff - enemy_payoff
  end

  def calculate_payoff(pieces, opposing_pieces, _current, _depth)
    move_payoffs = []
    rating = 0

    pieces.each do |piece|
      piece[:available_moves].each do |move|
        opposing_piece = attack_opposing_piece(move, opposing_pieces)

        # thread = Thread.new { determine_move_rating(piece, move, all_pieces, rating, current + 1, depth) }
        # rating = thread.value

        move_payoffs.push opposing_piece[:rating] unless opposing_piece.nil?
      end
    end

    return rating if move_payoffs.empty?

    (move_payoffs.sum(0.0) / move_payoffs.size) + rating
  end

  def attack_opposing_piece(move, opposing_pieces)
    opposing_pieces.select { |piece| piece[:position_x] == move[0] && piece[:position_y] == move[1] }.first
  end

  private

  def evaluate_position(piece, move)
    score = 0
    x, y = move[0], move[1]
    
    case piece[:piece_type].to_sym
    when :pawn
      score += evaluate_pawn_position(x, y, piece[:color])
    when :knight
      score += evaluate_knight_position(x, y)
    when :bishop
      score += evaluate_bishop_position(x, y)
    when :rook
      score += evaluate_rook_position(x, y)
    when :queen
      score += evaluate_queen_position(x, y)
    when :king
      score += evaluate_king_position(x, y, piece[:color])
    end
    
    score
  end

  def evaluate_pawn_position(x, y, color)
    score = 0
    # Encourage pawns to advance
    advance_value = color == 'white' ? (7 - y) : y
    score += advance_value * 0.1
    # Bonus for controlling center
    score += 0.2 if [3,4].include?(x)
    score
  end

  def evaluate_knight_position(x, y)
    # Knights are better near the center
    center_distance = Math.sqrt((x - 3.5)**2 + (y - 3.5)**2)
    0.5 * (4 - center_distance)
  end

  def evaluate_bishop_position(x, y)
    score = 0
    # Bishops are better on long diagonals
    score += 0.3 if (x - y).abs <= 1 || (x - (7 - y)).abs <= 1
    # Bonus for controlling center squares
    score += 0.2 if [2,3,4,5].include?(x) && [2,3,4,5].include?(y)
    score
  end

  def evaluate_rook_position(x, y)
    score = 0
    # Rooks are better on open files and 7th/2nd rank
    score += 0.3 if [0,7].include?(x)
    score += 0.4 if y == 1 || y == 6  # 7th/2nd rank
    score
  end

  def evaluate_queen_position(x, y)
    # Queens are slightly better near the center in the middlegame
    center_distance = Math.sqrt((x - 3.5)**2 + (y - 3.5)**2)
    0.2 * (4 - center_distance)
  end

  def evaluate_king_position(x, y, color)
    score = 0
    # Kings should stay back in early/middle game
    if color == 'white'
      score -= 0.5 * (7 - y)  # Penalize moving up
    else
      score -= 0.5 * y  # Penalize moving down
    end
    score
  end

  def sort_moves_by_priority(moves, all_pieces, game_phase)
    moves.sort_by do |move|
      score = 0
      piece = all_pieces.find { |p| p[:id] == move[:id] }
      
      # Capturing moves
      target = attack_opposing_piece(move[:position], all_pieces)
      if target
        score += PIECE_VALUES[target[:piece_type].to_sym] * 10
        score += 5 if is_piece_threatened?(target, all_pieces)
      end

      # Development in opening
      if game_phase == :opening
        score += 3 if is_development_move?(piece, move[:position])
      end

      # Control of key squares
      score += evaluate_square_control(move[:position], game_phase)

      # Piece safety
      score -= 5 if moves_into_danger?(piece, move[:position], all_pieces)

      score
    end.reverse
  end

  def determine_game_phase(all_pieces)
    material_count = all_pieces.sum { |p| PIECE_VALUES[p[:piece_type].to_sym] }
    developed_pieces = count_developed_pieces(all_pieces)

    if material_count >= 62 && developed_pieces < 6  # Starting material is 78
      :opening
    elsif material_count >= 30
      :middlegame
    else
      :endgame
    end
  end

  def count_developed_pieces(all_pieces)
    all_pieces.count do |piece|
      next if piece[:piece_type] == 'pawn' || piece[:piece_type] == 'king'
      piece[:color] == 'white' ? piece[:position_y] != 7 : piece[:position_y] != 0
    end
  end

  def is_development_move?(piece, new_pos)
    return false if piece[:piece_type] == 'pawn' || piece[:piece_type] == 'king'
    return false if piece[:moved]  # Avoid moving the same piece twice in opening
    
    if piece[:color] == 'white'
      piece[:position_y] == 7 && new_pos[1] != 7  # Moving from back rank
    else
      piece[:position_y] == 0 && new_pos[1] != 0
    end
  end

  def evaluate_square_control(position, game_phase)
    score = 0
    if CENTER_SQUARES.include?(position)
      score += game_phase == :opening ? 3 : 2
    elsif EXTENDED_CENTER.include?(position)
      score += game_phase == :opening ? 2 : 1
    end
    score
  end

  def is_piece_threatened?(piece, all_pieces)
    opposing_pieces = all_pieces.select { |p| p[:color] != piece[:color] }
    pos = [piece[:position_x], piece[:position_y]]
    
    opposing_pieces.any? do |attacker|
      attacker[:available_moves].include?(pos)
    end
  end

  def moves_into_danger?(piece, new_pos, all_pieces)
    # Simulate the move
    original_x, original_y = piece[:position_x], piece[:position_y]
    piece[:position_x], piece[:position_y] = new_pos[0], new_pos[1]
    
    # Check if the piece would be threatened
    threatened = is_piece_threatened?(piece, all_pieces)
    
    # Restore original position
    piece[:position_x], piece[:position_y] = original_x, original_y
    
    threatened
  end

  def get_opening_move(cpu_pieces, all_pieces)
    # Simple opening book implementation
    king_pawn = cpu_pieces.find { |p| p[:piece_type] == 'pawn' && p[:position_x] == 4 }
    queen_pawn = cpu_pieces.find { |p| p[:piece_type] == 'pawn' && p[:position_x] == 3 }
    knights = cpu_pieces.select { |p| p[:piece_type] == 'knight' && !p[:moved] }
    
    if king_pawn && !king_pawn[:moved]
      return create_move(king_pawn, [4, king_pawn[:position_y] - 2])
    elsif queen_pawn && !queen_pawn[:moved]
      return create_move(queen_pawn, [3, queen_pawn[:position_y] - 2])
    elsif knights.any?
      knight = knights.first
      target = knight[:position_x] == 1 ? [2, 5] : [5, 5]
      return create_move(knight, target)
    end
    
    nil
  end

  def create_move(piece, position)
    {
      id: piece[:id],
      color: piece[:color],
      position: position,
      rating: 10  # High rating for opening book moves
    }
  end

  def valid_position?(pos)
    pos[0].between?(0, 7) && pos[1].between?(0, 7)
  end
end
