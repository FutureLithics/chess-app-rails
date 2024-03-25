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
    assert_selector 'a', text: 'New Game'
    assert_selector 'p', text: /Select Opponent/
    assert_selector 'h3', text: @user.display_name
    assert_selector 'h4', text: /1/

    click_on("Vlad the Impaler")
    find('#chess_board')
  end
end
