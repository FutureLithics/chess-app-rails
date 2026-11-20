# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Playing against the computer', type: :system do
  let!(:player) { create(:user) }
  let!(:computer) { create(:user, :cpu, display_name: 'Ivan the Terrible') }

  before do
    login_as(player, scope: :user)
  end

  it 'creates a game and renders all pieces' do
    create_game

    expect(page).to have_css('#chess_board')
    expect(page).to have_css('#chess_board .square', count: 64)
    expect(page).to have_css('#chess_board img.svg-piece', count: 32)
  end

  it 'selects and moves a piece with JavaScript' do
    create_game
    visit game_room_path
    expect(page).to have_css('#chess_board')

    wait_for_stimulus_controller('#chess_board', 'piece')
    execute_script("document.querySelector(\"#{board_square(4, 6)}\").click()")

    expect(page).to have_css("#{board_square(4, 4)}.move-available")

    find(board_square(4, 4)).click

    expect(page).to have_css("#{board_square(4, 4)} img.pawn")
    expect(player_turns.count).to eq(1)
    expect(computer_turns.count).to eq(1)
  end

  private

  def create_game
    visit root_path
    click_on 'Play Now!'
    expect(page).to have_link('New Game')
    execute_script("document.querySelector(\"a[href='#{init_game_path}']\").click()")
    expect(page).to have_select('game_player_two')
    select computer.display_name, from: 'game_player_two'
    execute_script("document.querySelector(\"input[type='submit'][value='Create']\").click()")
    expect(page).to have_css('#chess_board')
  end

  def player_turns
    Turn.where(player_id: player.id)
  end

  def computer_turns
    Turn.where(player_id: computer.id)
  end
end
