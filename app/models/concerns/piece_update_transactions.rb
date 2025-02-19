# frozen_string_literal: true

module PieceUpdateTransactions
  extend ActiveSupport::Concern
  include ActiveModel::Dirty

  def commit_transactions
    log_message("🔄 Processing piece move transaction")
    update_turns
    set_check_if_king_threatened
  end

  def ensure_moved_set
    return if moved

    update_column(:moved, true)
  end

  private

  def update_turns
    log_message("📝 Creating turn record")
    create_turn
  end

  def create_turn
    Turn.create!(
      game_id: game.id,
      initial_x: position_x_was || position_x,
      initial_y: position_y_was || position_y,
      next_x: position_x,
      next_y: position_y,
      player_id: player_id
    )
  end

  def set_check_if_king_threatened
    check_if_pieces_threaten_king
  end

  def check_if_pieces_threaten_king
    # Get all active pieces and kings
    active_pieces = game.pieces.where(active: true)
    kings = active_pieces.where(piece_type: 'king')
    
    # Convert pieces to hashes for move calculation
    piece_hashes = active_pieces.map { |p| piece_to_hash(p) }
    
    # Check each king
    kings.each do |king|
      # Find pieces that could threaten the king
      threatening_pieces = active_pieces.where.not(color: king.color)
      
      # Check if any piece can move to the king's position
      is_threatened = threatening_pieces.any? do |piece|
        moves = ChessService.get_moves_by_piece(
          piece_to_hash(piece),
          piece_hashes
        )
        moves.any? { |move| move[0] == king.position_x && move[1] == king.position_y }
      end

      # Update the king's check status
      if is_threatened
        king.update_columns(checked: true)
        
        # Check for checkmate
        if detect_checkmate(king.color)
          game.set_checkmate(king.color)
        end
      else
        king.update_columns(checked: false)
      end
    end
  end

  def detect_checkmate(color)
    # Get all pieces of the checked color
    pieces = game.pieces.where(active: true, color: color)
    piece_hashes = pieces.map { |p| piece_to_hash(p) }
    all_piece_hashes = game.get_active_pieces
    
    # If any piece has valid moves, it's not checkmate
    pieces.none? do |piece|
      moves = ChessService.get_moves_by_piece(
        piece_to_hash(piece),
        all_piece_hashes
      )
      moves.any?
    end
  end

  def piece_to_hash(piece)
    {
      id: piece.id,
      piece_type: piece.piece_type.to_s,
      color: piece.color.to_s,
      position_x: piece.position_x.to_i,
      position_y: piece.position_y.to_i,
      rating: piece.rating.to_i,
      player_id: piece.player_id.to_i,
      active: piece.active,
      moved: piece.moved,
      available_moves: []
    }
  end

  def log_message(msg)
    if respond_to?(:cpu_log)
      Rails.logger.debug cpu_log(msg)
    else
      Rails.logger.debug msg
    end
  end
end
