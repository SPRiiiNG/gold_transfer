Rails.application.routes.draw do

  namespace :api, :defaults => {:format => :json} do

    post 'register', to: 'users#create'
    get 'transactions', to: 'transactions#index'
    post 'transactions/top_up', to: 'transactions#top_up'
    devise_for :users, controllers: {
      sessions: 'users/sessions'
    }
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
