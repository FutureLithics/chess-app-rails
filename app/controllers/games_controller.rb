# frozen_string_literal: true

class GamesController < ApplicationController
  def index; end

  def show
    @opponents = User.computer_opponents
  end

  def create
    puts params[:opponent]
  end

  def update; end

  def destroy; end
end
