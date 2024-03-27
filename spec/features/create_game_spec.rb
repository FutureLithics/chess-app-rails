require 'spec_helper'
require 'rails_helper'

feature "User can create a game" do
    before(:each) do
        @user = create(:user)
    end

    scenario "and all elements will be present" do
        visit root_url
        assert_selector 'h1', text: /Chess Application/
    
        click_on 'Play Now!'
        click_on 'New Game'
        assert_selector 'label', text: 'Select opponent:'
        assert_selector 'option', text: @user.display_name

        click_on 'Create'

        assert_selector '#chess_board'
    end
end