# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: {
    player: 'player',
    admin: 'admin',
    cpu: 'cpu'
  }

  scope :computer_opponents, -> { where(role: 'cpu') }
end
