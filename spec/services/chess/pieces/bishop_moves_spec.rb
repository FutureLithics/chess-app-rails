# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'Bishop Moves' do
  context 'basic moves' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @game.get_active_pieces.each { |piece| piece.update!(active: false) }
      @bishop = create(:piece,
                       game_id: @game[:id],
                       piece_type: 'bishop',
                       position_x: 3,
                       position_y: 4,
                       color: 'white')
    end

    it 'can move one space on start' do
      piece = ChessService.get_available_moves(@bishop, @game.get_active_pieces)
      extreme_moves = [[0, 1], [7, 0], [0, 7], [6, 7]]

      expect(piece[:available_moves]).to include(*extreme_moves)
    end

    it 'cannot land on a friendly piece' do
      @friendly_piece = create(:piece,
                               game_id: @game[:id],
                               position_x: 6,
                               position_y: 7)

      piece = ChessService.get_available_moves(@bishop, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end
  end
end
