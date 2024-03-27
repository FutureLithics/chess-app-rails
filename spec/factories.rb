# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    display_name { 'Vlad the Impaler' }
    email { 'vladtheimpaler@futurelithics.com' }
    password { 'password' }
    rank { 900 }
    level { 1 }
    role { 'cpu' }
  end
end
