# frozen_string_literal: true

module CpuMoves
  def determine_move(cpu_pieces, player_pieces)
    moves = create_moves_rating(cpu_pieces, player_pieces)

    return unless moves.count.positive?

    move = moves.max_by { |m| m[:rating] }

    update_piece(move)
  end

  def update_piece(move)
    piece = Piece.find_by_id(move[:id])

    piece.update!(position_x: move[:position][0], position_y: move[:position][1])
  end

  def create_moves_rating(cpu_pieces, player_pieces)
    moves = []
    all_pieces = (cpu_pieces + player_pieces).dup

    cpu_pieces.each do |piece|
      # moving the piece should add to rating if it is threatened
      rating = determine_initial_rating(piece, player_pieces)

      piece[:available_moves].map do |move|
        virtual_piece = all_pieces.select { |vp| vp[:id] == piece[:id] }.first
        rating = determine_move_rating(virtual_piece, move, all_pieces, rating)

        hash = {
          id: piece[:id],
          color: piece[:color],
          position: move,
          rating: rating
        }

        moves.push hash
      end
    end

    moves
  end

  def determine_initial_rating(piece, player_pieces)
    coordinates = [piece[:position_x], piece[:position_y]]

    return 0 unless player_pieces.any? { |p_piece| p_piece[:available_moves].include? coordinates }

    piece[:rating]
  end

  def determine_move_rating(piece, move, all_pieces, rating)
    color = piece[:color]
    piece[:id]

    # update the piece position with the move
    piece[:position_x] = move[0]
    piece[:position_y] = move[1]

    # get updated enemy available moves, determine if this piece or more valuable piece can be taken
    # average overall payoff of possible enemy moves

    check_virtual_payoffs(all_pieces, rating, color)
  end

  def check_virtual_payoffs(all_pieces, rating, color)
    friendly_pieces = all_pieces.select { |piece| piece[:color] == color }
    enemy_pieces = all_pieces.reject { |piece| piece[:color] == color }

    friendly_pieces = ChessService.get_available_moves_by_color(all_pieces, friendly_pieces)
    enemy_pieces = ChessService.get_available_moves_by_color(all_pieces, enemy_pieces)

    friendly_payoff = calculate_payoff(friendly_pieces, enemy_pieces)
    enemy_payoff = calculate_payoff(enemy_pieces, friendly_pieces)

    rating + friendly_payoff - enemy_payoff
  end

  def calculate_payoff(pieces, opposing_pieces)
    move_payoffs = []

    pieces.each do |piece|
      piece[:available_moves].each do |move|
        opposing_piece = attack_opposing_piece(move, opposing_pieces)

        move_payoffs.push opposing_piece[:rating] unless opposing_piece.nil?
      end
    end

    return 0 if move_payoffs.empty?

    move_payoffs.sum(0.0) / move_payoffs.size
  end

  def attack_opposing_piece(move, opposing_pieces)
    opposing_pieces.select { |piece| piece[:position_x] == move[0] && piece[:position_y] == move[1] }.first
  end
end
