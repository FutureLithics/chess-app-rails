# frozen_string_literal: true

module PieceUpdateTransactions
  extend ActiveSupport::Concern
  include ActiveModel::Dirty

  def commit_transactions
    ensure_moved_set
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
end
