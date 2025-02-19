# frozen_string_literal: true

module GamesHelper
  include LogHelper

  def display_user
    current_user.nil? ? 'Guest' : current_user.display_name
  end

  def restrict_actions_to_user(user, piece)
    return '' if piece.nil? || user.nil?
    user.id == piece[:player_id].to_i ? 'true' : ''
  end

  def chess_board
    Array.new(8) { Array.new(8) }
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
    return if pieces.nil?
    
    x = x.to_i
    y = y.to_i
    
    begin
      pieces.find { |p| p[:position_x].to_i == x && p[:position_y].to_i == y }
    rescue => e
      Rails.logger.error error_log("Error in piece_helper: #{e.message}")
      nil
    end
  end
end
