# frozen_string_literal: true

class BoardPresenter
  attr_accessor :user, :game

  def initialize(user = nil, game = nil)
    @game = game
    @user = user
  end

  def players
    if game.nil?
      [player_stats(user), nil]
    else
      player_one = User.find_by_id(game[:player_one])
      player_two = User.find_by_id(game[:player_two])

      [player_stats(player_one), player_stats(player_two)]
    end
  end

  def player_stats(player)
    if player.nil?
      { display_name: 'Guest', rank: 'N/A', level: 'N/A' }
    else
      { display_name: player[:display_name], rank: player[:rank], level: player[:level] }
    end
  end

  def in_progress?
    game.in_progress?
  end

  def pieces
    return if game.nil?

    pieces = game.get_active_pieces

    pieces.map do |piece|
      ChessService.get_available_moves(piece, pieces)
    end
  end
end
