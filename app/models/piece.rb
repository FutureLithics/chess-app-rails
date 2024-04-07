# frozen_string_literal: true

class Piece < ApplicationRecord
  belongs_to :game

  before_update :validate_move
  after_update :ensure_moved_set

  after_update_commit :send_updated_board_presenter

  private

  def validate_move
    valid = true
    game = Game.find_by_id(game_id)
    pieces = game.get_active_pieces

    occupier = position_occupier(pieces, self.position_x, self.position_y)
    valid = determine_enemy(occupier, color) unless occupier.nil?

    ensure_moved_set if valid

    valid
  end

  def is_in_available_moves(moves, position_x, position_y)
    p moves[:available_moves], position_x, position_y, "MOVES!!!"
    moves[:available_moves].any? { |m| m[0] == position_x && m[1] == position_y }
  end

  def position_occupier(pieces, pos_x, pos_y)
    pieces.select do |piece|
      piece[:position_x] == pos_x && piece[:position_y] == pos_y
    end.first
  end

  def determine_enemy(occupier, piece_color)
    if occupier[:color] != piece_color
      kill_piece(occupier)
    else
      false
    end
  end

  def ensure_moved_set
    unless self.moved
        self.moved = true
    end
  end

  def kill_piece(piece)
    piece.update(active: false)
  end

  def send_updated_board_presenter
    game = Game.find_by_id(game_id)
    presenter = BoardPresenter.new(nil, game)

    broadcast_update_to('move_updates', partial: 'games/partials/board', target: 'chess_board',
                                        locals: { presenter: presenter })
  end
end
