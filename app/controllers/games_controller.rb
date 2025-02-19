# frozen_string_literal: true

class GamesController < ApplicationController
  helper_method :current_or_guest_user

  def index; end

  def new
    @game = Game.new
    @opponents = User.computer_opponents
  end

  def show
    game = Game.active_game_by_user(current_or_guest_user).last
    @user = current_or_guest_user

    @presenter = BoardPresenter.new(current_or_guest_user, game)
  end

  def create
    opponent = game_params[:player_two]
    
    game = Game.new(
      player_one: current_or_guest_user.id, 
      player_two: opponent
    )

    if game.save
      Rails.logger.debug "Game created with player_one: #{game.player_one}, player_two: #{game.player_two}"
      Rails.logger.debug "Player two is CPU? #{game.player_two_user&.cpu?}"
      
      @presenter = BoardPresenter.new(current_or_guest_user, game)
      @user = current_or_guest_user

      respond_to do |format|
        format.html { redirect_to game_room_path }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def move
    piece = Piece.find_by_id(move_params[:piece_id])
    x = move_params[:position_x].to_i
    y = move_params[:position_y].to_i

    Rails.logger.debug "Attempting to move piece #{piece.inspect} to position (#{x}, #{y})"

    # Validate the move position
    if !x.between?(0, 7) || !y.between?(0, 7)
      Rails.logger.error "Invalid move position: (#{x}, #{y})"
      return render json: { success: false, error: 'Invalid move position' }, status: :unprocessable_entity
    end

    # Check for captures
    captured_piece = piece.game.pieces.find_by(
      position_x: x,
      position_y: y,
      active: true
    )
    
    begin
      Piece.transaction do
        # Handle the capture if there is one
        if captured_piece
          Rails.logger.debug "Capturing piece: #{captured_piece.inspect}"
          captured_piece.update!(active: false)
        end

        # Move the piece
        Rails.logger.debug "Moving piece from (#{piece.position_x}, #{piece.position_y}) to (#{x}, #{y})"
        valid_move = piece.update!(
          position_x: x,
          position_y: y,
          moved: true,
          active: true
        )

        if valid_move
          game = piece.game
          presenter = BoardPresenter.new(current_or_guest_user, game)

          # Broadcast player's move
          piece.broadcast_update_to(
            :move_updates, 
            partial: 'games/partials/board', 
            target: 'chess_board',
            locals: { presenter: presenter, user: current_or_guest_user }
          )

          data = send_end_game_state(game)
          if data
            game.broadcast_replace_to(
              :game_state, 
              partial: 'games/partials/modal', 
              target: 'game_modal',
              locals: { message: data }
            )
          end

          render json: { success: true }
        else
          render json: { success: false, error: 'Move invalid' }, status: :unprocessable_entity
        end
      end
    rescue => e
      Rails.logger.error "Error moving piece: #{e.message}\n#{e.backtrace.join("\n")}"
      render json: { success: false, error: e.message }, status: :unprocessable_entity
    end
  end

  def update; end

  def destroy; end

  private

  def game_params
    params.require(:game).permit(:player_two)
  end

  def move_params
    params.require(:move).permit(:piece_id, :position_x, :position_y)
  end

  def send_end_game_state(game)
	data = {title: "", message: "", class_name: ""}

	if game.checkmate?
		win = current_or_guest_user.id == game.winner
		data[:title] = "Checkmate!"
		data[:message] = win ? "Congratulations, You Won!" : "Sorry, You Lost..."
		data[:class_name] = win ? "win" : "lose"
	elsif game.stalemate?
		data[:title] = "Stalemate..."
		data[:message] = "You both lost. Good try"
		data[:class_name] = "stalemate"
	else
		data = nil
	end

	data
  end
end
