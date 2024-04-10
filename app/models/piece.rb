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

    determine_en_passant_attack(pieces) # must be first before all en_passant is reset to false
    mark_pawn_en_passant(pieces)

    occupier = position_occupier(pieces, position_x, position_y)
    valid = determine_enemy(occupier, color) unless occupier.nil?

    ensure_moved_set if valid

    valid
  end

  def is_in_available_moves(moves, position_x, position_y)
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
    return if moved

    self.moved = true
  end

  def kill_piece(piece)
    piece.update(active: false)
  end

  def determine_en_passant_attack(pieces)
    # return if piece isn't a pawn or hasn't moved diagonally
    return if piece_type != 'pawn' || (position_x - position_x_was).abs == 0

    pieces.select do |piece|
        if piece[:en_passant] && piece[:color] != color && position_y_was == piece[:position_y]
            kill_piece(piece)
        end
    end
  end

  def send_updated_board_presenter
    game = Game.find_by_id(game_id)
    presenter = BoardPresenter.new(nil, game)

    broadcast_update_to('move_updates', partial: 'games/partials/board', target: 'chess_board',
                                        locals: { presenter: presenter })
  end

  def mark_all_en_passant_false(pieces)
    pieces.each do |piece|
        if piece.en_passant?
            piece.en_passant = false
        end
    end
  end

  def mark_pawn_en_passant(pieces)
    # all en_passant should be falsified after every turn
    mark_all_en_passant_false(pieces)

    if piece_type == "pawn" && (position_y_was - position_y).abs == 2
        self.en_passant = true
    end
  end
end
