# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe "Game Initialization" do
    before(:each) do
        @user1 = create(:user, id: 0)
        @user2 = create(:user, id:1, display_name: "Ivan", email: "ivan@futurelithics.com")
        @game = create(:game)
    end

    it "Initializes all pieces" do
        assert true
    end


end