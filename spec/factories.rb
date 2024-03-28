# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    id {0}
    display_name { 'Vlad the Impaler' }
    email { 'vladtheimpaler@futurelithics.com' }
    password { 'password' }
    rank { 900 }
    level { 1 }
    role { 'cpu' }
  end

  factory :game do
    player_one { 0 }
    player_two { 1 }
  end
end
