# frozen_string_literal: true

class Piece < ApplicationRecord
  include MoveDetection
  include PieceUpdateTransactions
  include LogHelper

  belongs_to :game

  before_update :validate_move
  after_update :commit_transactions

  validates :position_x, numericality: { greater_than_or_equal_to: 0, less_than: 8 }
  validates :position_y, numericality: { greater_than_or_equal_to: 0, less_than: 8 }

  def validate_move
    Rails.logger.debug cpu_log("🎯 Validating move for piece: #{piece_type}")
    
    # Validate position is within board boundaries
    if position_x.negative? || position_x > 7 || position_y.negative? || position_y > 7
      Rails.logger.error error_log("❌ Invalid position: (#{position_x}, #{position_y})")
      return false
    end
    
    true
  end
end
