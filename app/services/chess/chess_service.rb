# frozen_string_literal: true

class ChessService < ApplicationService
    include GameInitializer

    attr_accessor :game

    def initialize(game)
        @game = game

        initialize_pieces(game)
    end

end
