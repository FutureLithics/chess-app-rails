# frozen_string_literal: true

FactoryBot.define do
  factory :turn do
  end

  factory :user do
    sequence(:display_name) { |number| "Player #{number}" }
    sequence(:email) { |number| "player-#{number}@example.com" }
    password { 'password' }
    rank { 900 }
    level { 1 }
    role { 'player' }

    trait :cpu do
      role { 'cpu' }
    end

    trait :guest do
      guest { true }
    end
  end

  factory :game do
    player_one { 0 }
    player_two { 1 }
  end

  factory :piece do
    piece_type { 'pawn' }
    color { 'white' }
    position_x { 4 }
    position_y { 6 }
    active { true }
    moved { false }
  end
end
