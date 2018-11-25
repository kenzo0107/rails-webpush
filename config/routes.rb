# frozen_string_literal: true

Rails.application.routes.draw do
  resources :user_sessions
  resources :users, only: %w[new create show]
  resource :user, only: %w[edit update]

  root 'top#index'
  get 'article', to: 'article#index'

  get 'login' => 'user_sessions#new', as: :login
  post 'logout' => 'user_sessions#destroy', as: :logout

  resources :webpush_subscriptions, only: [:create]
end
