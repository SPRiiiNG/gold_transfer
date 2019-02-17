Rails.application.routes.draw do

  

  namespace :api, :defaults => {:format => :json} do

    post 'register', to: 'users#create'


    devise_for :users, controllers: {
      sessions: 'users/sessions'
    }
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
