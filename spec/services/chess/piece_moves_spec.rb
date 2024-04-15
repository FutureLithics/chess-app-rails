# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'Piece Moves' do
  context 'do not include moves that expose king in available_moves' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @game.get_active_pieces.each(&:destroy)
      @king = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'king',
                     position_x: 4,
                     position_y: 7,
                     color: 'white',
                     moved: false)
    end

    context 'rook cannot allow threat' do
      it 'from enemy piece' do
        @friendly_rook = create(:piece,
                                game_id: @game[:id],
                                piece_type: 'rook',
                                position_x: 4,
                                position_y: 6,
                                color: 'white',
                                moved: true)

        @enemy_rook = create(:piece,
                             game_id: @game[:id],
                             piece_type: 'rook',
                             position_x: 4,
                             position_y: 0,
                             color: 'black',
                             moved: true)

        piece = ChessService.get_available_moves(@friendly_rook, @game.get_active_pieces)

        expect(piece[:available_moves]).to_not include [3, 6]
        expect(piece[:available_moves]).to_not include [4, 6]
        expect(piece[:available_moves]).to include [4, 0]
      end
    end
  end
end
