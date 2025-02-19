# frozen_string_literal: true

class Game < ApplicationRecord
  include LogHelper
  enum :player_turn, %i[white_turn black_turn]
  enum :game_state, %i[in_progress checkmate stalemate resigned abandoned]

  after_create :initialize_game, unless: :skip_callbacks

  has_many :pieces
  has_many :turns

  belongs_to :player_one_user, class_name: 'User', foreign_key: 'player_one', optional: true
  belongs_to :player_two_user, class_name: 'User', foreign_key: 'player_two', optional: true

  scope :active_game_by_user, ->(user) { where(player_one: user).or(where(player_two: user)) }

  def get_active_pieces
    # Remove the verbose piece logging
    active_pieces = pieces.where(active: true)
    
    active_pieces.map do |piece|
      {
        id: piece.id,
        piece_type: piece.piece_type.to_s,
        color: piece.color.to_s,
        position_x: piece.position_x.to_i,
        position_y: piece.position_y.to_i,
        rating: piece.rating.to_i,
        player_id: piece.player_id.to_i,
        active: piece.active,
        moved: piece.moved,
        available_moves: []
      }
    end
  end

  def get_active_pieces_by_color(color)
    get_active_pieces.select { |piece| piece[:color] == color.to_s }
  end

  def get_player_by_turn
    current = if white_turn?
      Rails.logger.debug cpu_log("🎯 White's turn (Player One)")
      player_one
    else
      Rails.logger.debug cpu_log("🎯 Black's turn (Player Two)")
      player_two
    end
    current
  end

  def set_checkmate(color)
    checkmate!

    winner = if color == 'white'
               player_two
             else
               player_one
             end

    update!(winner: winner)
  end

  def cpu_move
    Rails.logger.debug cpu_log("🎮 CPU MOVE STARTED")
    color = white_turn? ? 'white' : 'black'
    
    all_pieces = get_active_pieces
    cpu_pieces = all_pieces.select { |piece| piece[:color] == color && piece[:player_id].to_i == player_two.to_i }
    
    if cpu_pieces.empty?
      Rails.logger.error error_log("❌ No CPU pieces found")
      return nil
    end
    
    player_pieces = all_pieces - cpu_pieces
    
    begin
      cpu_pieces = ChessService.get_available_moves_by_color(all_pieces, cpu_pieces)
      player_pieces = ChessService.get_available_moves_by_color(all_pieces, player_pieces)
      
      move = ChessService.cpu_move(cpu_pieces, player_pieces)
      
      if move
        piece = pieces.find(move[:id])
        
        if piece
          begin
            Piece.transaction do
              # Check if there's a piece at the target position
              captured_piece = pieces.find_by(
                position_x: move[:position][0],
                position_y: move[:position][1],
                active: true
              )
              
              # If there is a piece, mark it as captured
              if captured_piece
                Rails.logger.debug cpu_log("♟️ Capturing #{captured_piece.piece_type}")
                captured_piece.update!(active: false)
              end

              # Move the piece
              Rails.logger.debug cpu_log("♟️ Moving #{piece.piece_type} to (#{move[:position].join(',')})")
              result = piece.update!(
                position_x: move[:position][0],
                position_y: move[:position][1],
                moved: true,
                active: true
              )
              
              # Create a turn for the CPU move
              Turn.create!(
                game_id: id,
                initial_x: piece.position_x_was,
                initial_y: piece.position_y_was,
                next_x: piece.position_x,
                next_y: piece.position_y,
                player_id: player_two
              )
              
              # Get the CPU player and broadcast
              cpu_player = player_two_user
              presenter = BoardPresenter.new(cpu_player, self)
              broadcast_update_to(
                :move_updates,
                partial: 'games/partials/board',
                target: 'chess_board',
                locals: { 
                  presenter: presenter, 
                  user: cpu_player
                }
              )
            end
          rescue => e
            Rails.logger.error error_log("💥 Error in CPU move: #{e.message}")
            Rails.logger.error error_log(e.backtrace.join("\n"))
            return nil
          end
        else
          Rails.logger.error error_log("Could not find piece with id: #{move[:id]}")
        end
      else
        Rails.logger.error error_log("❌ No valid move was selected")
      end
    rescue => e
      Rails.logger.error error_log("💥 Error in CPU move: #{e.message}")
      Rails.logger.error error_log(e.backtrace.join("\n"))
      return nil
    end

    move
  end

  def toggle_turn!
    begin
      new_turn = if white_turn?
        Rails.logger.debug cpu_log("🔄 Switching to black's turn")
        :black_turn
      else
        Rails.logger.debug cpu_log("🔄 Switching to white's turn")
        :white_turn
      end
      
      update!(player_turn: new_turn)
      reload
    rescue => e
      Rails.logger.error error_log("💥 Error in toggle_turn!: #{e.message}")
      raise e
    end
  end

  # Helper methods for players
  def player_one_user
    User.find_by(id: player_one)
  end

  def player_two_user
    User.find_by(id: player_two)
  end

  private

  def initialize_game
    Rails.logger.debug "Initializing new game with players: #{player_one}, #{player_two}"
    ChessService.new(self)
  end
end
