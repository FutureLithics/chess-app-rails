# frozen_string_literal: true

module GamesHelper
    def display_user
        current_user.nil? ? 'Guest' : current_user.display_name
    end

    def chess_board
        Array.new(8, Array.new(8))
    end

    def define_square(x, y)
        color_start = x.even? ? false : true

        if color_start
            y.even? ? { x: x, y: y, color: 0 } : { x: x, y: y, color: 1 }
        else
            y.even? ? { x: x, y: y, color: 1 } : { x: x, y: y, color: 0 }
        end
    end

    def opponent_selections
        return ['No Opponents Available', nil] if @opponents.nil?

        @opponents.map do |opponent|
            display = "#{opponent.display_name} \nLevel: #{opponent.level}"

            [display, opponent.id]
        end
    end

    def piece_helper(pieces, x, y)
        unless pieces.nil?
            collection = pieces.select { |piece|  piece[:position_x].to_i == x && piece[:position_y].to_i == y }

            collection[0]
        end
    end
end
