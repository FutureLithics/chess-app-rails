# frozen_string_literal: true

class Piece < ApplicationRecord
  include MoveDetection
  include PieceUpdateTransactions

  belongs_to :game

  before_update :validate_move
  after_update :commit_transactions
end
