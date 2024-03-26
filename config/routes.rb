# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  get 'games' => 'games#index', as: :games_page
  get 'game_room' => 'games#show'
  get 'new_game' => 'games#new', as: :init_game
  post 'games' => 'games#create', as: :new_game

  resources :games

  get 'pages/landing'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # Defines the root path route ("/")
  root 'pages#landing'
end
