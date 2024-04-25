# frozen_string_literal: true

module MoveDetection
  extend ActiveSupport::Concern

  included do
    def validate_move
      valid = true
      game = Game.find_by_id(game_id)
      pieces = game.get_active_pieces.dup

      set_check_if_king_threatened(pieces)
      determine_en_passant_attack(pieces) # must be first before all en_passant is reset to false
      detection_castle_move(pieces)
      mark_pawn_en_passant(pieces)

      occupier = position_occupier(pieces, position_x, position_y)
      valid = determine_enemy(occupier, color) unless occupier.nil?

      ensure_moved_set if valid

      valid
    end

    def is_in_available_moves(_moves, _position_x, _position_y)
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

    def kill_piece(piece)
      piece.update(active: false)
    end

    def determine_en_passant_attack(pieces)
      # return if piece isn't a pawn or hasn't moved diagonally
      return if piece_type != 'pawn' || (position_x - position_x_was).abs.zero?

      pieces.select do |piece|
        kill_piece(piece) if piece[:en_passant] && piece[:color] != color && position_y_was == piece[:position_y]
      end
    end

    def mark_all_en_passant_false(pieces)
      pieces.each do |piece|
        piece.update_columns(en_passant: false) if piece.en_passant?
      end
    end

    def mark_pawn_en_passant(pieces)
      # all en_passant should be falsified after every turn
      mark_all_en_passant_false(pieces)

      return unless piece_type == 'pawn' && (position_y_was - position_y).abs == 2

      self.en_passant = true
    end

    def detection_castle_move(pieces)
      return if piece_type != 'king' || (position_x_was - position_x).abs < 2

      piece = if (position_x_was - position_x).positive?
                position_occupier(pieces, 0, position_y)
              else
                position_occupier(pieces, 7, position_y)
              end
      transition_rook(piece)
    end

    def transition_rook(rook)
      return if rook.nil? || rook[:piece_type] != 'rook'

      if rook[:position_x].zero?
        rook.update_columns(position_x: 3, moved: true)
      else
        rook.update_columns(position_x: 5, moved: true)
      end
    end

    def set_check_if_king_threatened(pieces)
      kings = pieces.select { |piece| piece[:piece_type] == 'king' }

      black_king = kings.select { |king| king[:color] == 'black' }.first
      check_if_pieces_threaten_king(black_king, pieces, 'white')

      white_king = kings.select { |king| king[:color] == 'white' }.first
      check_if_pieces_threaten_king(white_king, pieces, 'black')
    end

    def check_if_pieces_threaten_king(king, pieces, color)
      return if king.nil? # generally only a problem in tests

      color_pieces = pieces.select { |piece| piece[:color] == color }

      color_pieces = ChessService.get_available_moves_by_color(pieces, color_pieces)

      color_pieces.each do |piece|
        piece[:available_moves].each do |move|
          if king[:position_x] == move[0] && king[:position_y] == move[1]
            king.update_columns(checked: true)

            game.set_checkmate(king[:color]) if detect_check_or_stalemate(pieces, king[:color])

            return
          elsif king[:checked]
            king.update_columns(checked: false)
          end
        end
      end
    end

    def detect_check_or_stalemate(pieces, color)
      color_pieces = pieces.select { |piece| piece[:color] == color }

      color_pieces = ChessService.get_available_moves_by_color(pieces, color_pieces)

      color_pieces.all? { |piece| piece[:available_moves].empty? }
    end
  end
end
