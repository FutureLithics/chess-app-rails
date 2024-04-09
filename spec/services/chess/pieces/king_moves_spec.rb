# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'King Moves' do
  context 'basic moves' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @game.get_active_pieces.each { |piece| piece.update!(active: false) }
      @king = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'king',
                     position_x: 3,
                     position_y: 4,
                     color: 'white')
    end

    it 'can move one space on start' do
      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)
      moves = [[4, 4], [4, 5], [4, 3], [3, 3], [3, 5], [2, 3], [2, 4], [2, 5]]

      expect(piece[:available_moves]).to include(*moves)
    end

    it 'cannot land on a friendly piece' do
      @friendly_piece = create(:piece,
                               game_id: @game[:id],
                               position_x: 4,
                               position_y: 4)

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [4, 4]
    end
  end
end
