# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'Piece Moves' do
  context 'for pawns' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @pawn = create(:piece, game_id: @game[:id])
    end

    it 'can move one space on start' do
      piece = ChessService.get_available_moves(@pawn, @game.get_active_pieces)

      expect(piece[:available_moves]).to include [4, 5]
    end

    it 'can move to two spaces on start' do
      piece = ChessService.get_available_moves(@pawn, @game.get_active_pieces)

      expect(piece[:available_moves]).to include [4, 4]
    end

    it 'cannot move forward against another piece' do
      @enemy_pawn = create(:piece, position_x: 4, position_y: 4, color: 'black', game_id: @game[:id])

      piece = ChessService.get_available_moves(@pawn, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [4, 4]
    end

    it 'can move diagonal only when attacking enemy pawns' do
      @enemy_pawn_left = create(:piece, position_x: 3, position_y: 5, color: 'black', game_id: @game[:id])
      @enemy_pawn_right = create(:piece, position_x: 5, position_y: 5, color: 'black', game_id: @game[:id])

      piece = ChessService.get_available_moves(@pawn, @game.get_active_pieces)

      expect(piece[:available_moves]).to include [3, 5]
      expect(piece[:available_moves]).to include [5, 5]
    end

    it 'can move diagonal only when attacking enemy pawns' do
      @friendly_pawn_left = create(:piece, position_x: 3, position_y: 5, color: 'white', game_id: @game[:id])
      @friendly_pawn_right = create(:piece, position_x: 5, position_y: 5, color: 'white', game_id: @game[:id])

      piece = ChessService.get_available_moves(@pawn, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [3, 4]
      expect(piece[:available_moves]).to_not include [5, 4]
    end
  end

  context 'for knights' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @game.get_active_pieces.each { |piece| piece.update!(active: false) }
      @knight = create(:piece,
                       game_id: @game[:id],
                       piece_type: 'knight',
                       position_x: 3,
                       position_y: 4,
                       color: 'white')
    end

    it 'can move one space on start' do
      piece = ChessService.get_available_moves(@knight, @game.get_active_pieces)
      expected_moves = [[2, 6], [4, 6], [1, 5], [5, 5], [2, 2], [4, 2], [1, 3], [5, 3]]

      expect(piece[:available_moves]).to match_array expected_moves
    end

    it 'cannot land on a friendly piece' do
      @friendly_piece = create(:piece,
                               game_id: @game[:id],
                               position_x: 2,
                               position_y: 6)

      piece = ChessService.get_available_moves(@knight, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [2, 6]
    end
  end
end
