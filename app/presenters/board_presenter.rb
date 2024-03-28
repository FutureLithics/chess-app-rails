# frozen_string_literal: true

class BoardPresenter
  attr_accessor :user, :game

  def initialize(user, game = nil)
    @game = game
    @user = user
  end

  def players
    if @game.nil?
      [player_stats(user), nil]
    else
      player_one = User.find_by_id(game.player_one)
      player_two = User.find_by_id(game.player_two)

      [player_stats(player_one), player_stats(player_two)]
    end
  end

  def player_stats(player)
    if player.nil?
      { display_name: 'Guest', rating: 'N/A', level: 'N/A' }
    else
      { display_name: player[:display_name], rating: player[:rank], level: player[:level] }
    end
  end

  def pieces
    unless @game.nil?
        game.get_active_pieces
    end
  end
end
