# frozen_string_literal: true

require 'application_system_test_case'

class GamesTest < ApplicationSystemTestCase
  setup do
    @user = users(:first)
  end

  test 'visiting the landing page to create new game' do
    visit root_url
    assert_selector 'h1', text: /Chess Application/

    click_on 'Play Now!'
    click_on 'New Game'
    assert_selector 'label', text: 'Select Opponent:'
    assert_selector 'option', text: @user.display_name

    find('#chess_board')
  end
end
