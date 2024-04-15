# frozen_string_literal: true

class Piece < ApplicationRecord
  include MoveDetection

  belongs_to :game

  before_update :validate_move
  after_update :ensure_moved_set

end
