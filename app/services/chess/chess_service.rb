# frozen_string_literal: true

class ChessService < ApplicationService
    include GameInitializer
    extend PieceMoves

    attr_accessor :game

    def initialize(game)
        @game = game

        initialize_pieces(game)
    end

    def self.get_available_moves(piece)
        get_moves_by_piece(piece)
    end

end
