# frozen_string_literal: true

module GameInitializer
  attr_accessor :game

  PIECES = YAML.load_file(Rails.root.join('app', 'services', 'chess', 'pieces.yml'))

  def initialize_pieces
    return unless @game # Skip if no game (for static method calls)
    
    Rails.logger.debug "Initializing pieces for game #{@game.id}"
    Rails.logger.debug "Player One: #{@game.player_one}, Player Two: #{@game.player_two}"

    # White pieces (Player One)
    create_pawns('white', @game.player_one)
    create_back_row('white', @game.player_one)

    # Black pieces (Player Two)
    create_pawns('black', @game.player_two)
    create_back_row('black', @game.player_two)
  end

  private

  def create_pawns(color, player_id)
    y = color == 'white' ? 6 : 1
    8.times do |x|
      Piece.create!(
        game: @game,
        piece_type: 'pawn',
        color: color,
        position_x: x,
        position_y: y,
        player_id: player_id,
        active: true
      )
    end
  end

  def create_back_row(color, player_id)
    y = color == 'white' ? 7 : 0
    pieces = %w[rook knight bishop queen king bishop knight rook]
    
    pieces.each_with_index do |piece_type, x|
      Piece.create!(
        game: @game,
        piece_type: piece_type,
        color: color,
        position_x: x,
        position_y: y,
        player_id: player_id,
        active: true
      )
    end
  end
end
