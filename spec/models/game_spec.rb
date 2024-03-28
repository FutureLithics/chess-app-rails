# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe Game, 'initialize' do
    before(:each) do
        @user1 = create(:user, id: 0)
        @user2 = create(:user, id:1, display_name: "Ivan", email: "ivan@futurelithics.com")
        @game = create(:game)
    end

    it "creates 32 pieces" do
        pieces_count = @game.pieces.count

        expect(pieces_count).to eq(32)
    end
end