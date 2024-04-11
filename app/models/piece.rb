# frozen_string_literal: true

class Piece < ApplicationRecord
  include MoveDetection

  belongs_to :game

  before_update :validate_move
  after_update :ensure_moved_set

  after_update_commit lambda {
    game = Game.find_by_id(game_id)
    user = User.find_by_id(player_id)
    presenter = BoardPresenter.new(nil, game)

    broadcast_update_to(:move_updates, partial: 'games/partials/board', target: 'chess_board',
                                       locals: { presenter: presenter, user: user })
  }
end
