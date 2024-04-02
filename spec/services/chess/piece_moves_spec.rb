# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe "Piece Moves" do
    context "for pawns" do
        before(:each) do
            @pawn = create(:piece)
        end

        it "can move one space on start" do
            piece = ChessService.get_available_moves(@pawn)

            expect(piece[:available_moves]).to include [0,5]
        end

        it "can move to two spaces on start" do
            piece = ChessService.get_available_moves(@pawn)

            expect(piece[:available_moves]).to include [0,4]
        end
    end


end