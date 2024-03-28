module GameInitializer
    attr_accessor :game

    PIECES = YAML.load_file(Rails.root.join("app", "services", "chess", "pieces.yml"))

    def initialize_pieces(game)
        @game = game

        create_pieces(PIECES["white"], game[:player_one], "white")
        create_pieces(PIECES["black"], game[:player_two], "black")
    end

    def create_pieces(pieces, player_id, color)
        pieces.each do |key, values|
            attributes = {player_id: player_id, game_id: game.id, color: color}

            Piece.create(values.merge(attributes))
        end
    end
end