# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def guest_user_params
    { display_name: 'Guest User Ahh!!!' }
  end
end
