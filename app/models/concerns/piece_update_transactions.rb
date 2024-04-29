# frozen_string_literal: true

module PieceUpdateTransactions
  extend ActiveSupport::Concern
  include ActiveModel::Dirty

  def commit_transactions
    ensure_moved_set
    @pieces = game.get_active_pieces
    set_check_if_king_threatened
    update_turns
  end

  def ensure_moved_set
    return if moved

    update_column(:moved, true)
  end

  def update_turns
    create_turn if was_move?
  end

  def was_move?
    (position_x - position_x_before_last_save).abs.positive? || (position_y - position_y_before_last_save).abs.positive?
  end

  def create_turn
    turn = Turn.new(initial_x: position_x_before_last_save, initial_y: position_y_before_last_save,
                    next_x: position_x, next_y: position_y, player_id: player_id, game_id: game_id)

    turn.save!
  end

  def set_check_if_king_threatened
    kings = @pieces.select { |piece| piece[:piece_type] == 'king' }

    black_king = kings.select { |king| king[:color] == 'black' }.first
    check_if_pieces_threaten_king(black_king, 'white')

    white_king = kings.select { |king| king[:color] == 'white' }.first
    check_if_pieces_threaten_king(white_king, 'black')
  end

  def check_if_pieces_threaten_king(king, color)
    return if king.nil? # generally only a problem in tests

    color_pieces = @pieces.select { |piece| piece[:color] == color }

    color_pieces = ChessService.get_available_moves_by_color(@pieces, color_pieces)

    color_pieces.each do |piece|
      piece[:available_moves].each do |move|
        if king[:position_x] == move[0] && king[:position_y] == move[1]
          king.update_columns(checked: true)

          game.set_checkmate(king[:color]) if detect_check_or_stalemate(king[:color])

          return
        elsif king[:checked]
          king.update_columns(checked: false)
        end
      end
    end
  end

  def detect_check_or_stalemate(color)
    color_pieces = @pieces.select { |piece| piece[:color] == color }

    color_pieces = ChessService.get_available_moves_by_color(@pieces, color_pieces)

    color_pieces.all? { |piece| piece[:available_moves].empty? }
  end
end
