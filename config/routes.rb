require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :staffs

  devise_scope :staff do
    root to: "staffs/sessions#new"
  end
  
  get 'welcome', to: "home#welcome"

  resources :transactions do
    member do
      put :approve
      put :reject
    end
  end

  namespace :api, :defaults => {:format => :json} do
    post 'register', to: 'users#create'
    get 'transactions', to: 'transactions#index'
    post 'transactions/top_up', to: 'transactions#top_up'
    post 'transactions/withdraw', to: 'transactions#withdraw'
    post 'transactions/buy', to: 'transactions#buy'
    post 'transactions/sell', to: 'transactions#sell'
    get 'balance', to: 'balances#show'

    devise_for :users, controllers: {
      sessions: 'users/sessions'
    }
  end

  mount Sidekiq::Web => '/sidekiq'
end
