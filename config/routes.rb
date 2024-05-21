Rails.application.routes.draw do
  resources :operational_states
  resources :cards do
    collection do
      get :sindex
    end
    member do
      post :get_certificate
      post :get_card
    end
  end
  resources :card_terminals do
    collection do
      get :sindex
    end
    member do
      get :ping
    end
  end
  resources :contexts
  resources :connectors do
    collection do
      get :sindex
    end
    member do
      post :fetch_sds
      post :get_resource_information
      post :get_card_terminals
      post :get_cards
      get :ping
    end
  end
  resources :locations
  root to: 'home#index'
  get 'home/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  mount Wobauth::Engine, at: '/auth'
  authenticate :user, ->(user) { user.is_admin? } do
    mount GoodJob::Engine => "good_job"
  end

end
