# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe 'King Moves' do
  context 'basic moves' do
    before(:each) do
      @user1 = create(:user, id: 0)
      @user2 = create(:user, id: 1, display_name: 'Ivan', email: 'ivan@futurelithics.com')
      @game = create(:game)
      @game.get_active_pieces.each(&:destroy)
      @king = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'king',
                     position_x: 4,
                     position_y: 4,
                     color: 'white',
                     moved: false)
    end

    it 'can move one space on start' do
      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)
      moves = [[5, 4], [5, 5], [5, 3], [4, 3], [4, 5], [3, 3], [3, 4], [3, 5]]

      expect(piece[:available_moves]).to include(*moves)
    end

    it 'cannot land on a friendly piece' do
      @friendly_piece = create(:piece,
                               game_id: @game[:id],
                               position_x: 5,
                               position_y: 4)

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [5, 4]
    end

    it 'castle with right rook' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 7,
                     position_y: 4,
                     color: 'white')

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to include [6, 4]
    end

    it 'castle with left rook' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 0,
                     position_y: 4,
                     color: 'white')

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to include [2, 4]
    end

    it 'cannot with right rook if piece between' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 7,
                     position_y: 4,
                     color: 'white')

      @friendly = create(:piece,
                         game_id: @game[:id],
                         position_x: 6,
                         position_y: 4,
                         color: 'white')

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end

    it 'cannot with left rook if piece between' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 0,
                     position_y: 4,
                     color: 'white')

      @friendly = create(:piece,
                         game_id: @game[:id],
                         position_x: 2,
                         position_y: 4,
                         color: 'white')

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [2, 7]
    end

    it 'cannot with right rook if rook moved' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 7,
                     position_y: 4,
                     color: 'white',
                     moved: true)

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end

    it 'cannot with left rook if rook moved' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 0,
                     position_y: 4,
                     color: 'white',
                     moved: true)

      piece = ChessService.get_available_moves(@king, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end

    it 'cannot with right rook if king moved' do
      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 7,
                     position_y: 4,
                     color: 'white')

      @king_moved = create(:piece,
                           game_id: @game[:id],
                           piece_type: 'king',
                           position_x: 4,
                           position_y: 4,
                           color: 'white',
                           moved: true)

      piece = ChessService.get_available_moves(@king_moved, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end

    it 'cannot with left rook if king moved' do
      @king_moved = create(:piece,
                           game_id: @game[:id],
                           piece_type: 'king',
                           position_x: 4,
                           position_y: 4,
                           color: 'white',
                           moved: true)

      @rook = create(:piece,
                     game_id: @game[:id],
                     piece_type: 'rook',
                     position_x: 0,
                     position_y: 4,
                     color: 'white')

      piece = ChessService.get_available_moves(@king_moved, @game.get_active_pieces)

      expect(piece[:available_moves]).to_not include [6, 7]
    end
  end
end
