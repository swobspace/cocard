Rails.application.routes.draw do
  get "reports/duplicate_terminal_ips"
  resources :ti_clients do
    resources :kt_proxies, module: :ti_clients, only: [:index]
  end
  resources :kt_proxies
  get "idle_messages", to: "idle_messages#index", as: :idle_messages
  get "idle_messages/edit"
  put "idle_messages", to: "idle_messages#update"

  resources 'situation_picture', only: [:index, :update] do
    collection do
      get :failed
    end
  end
  get 'verify_pins', to: 'verify_pins#index'
  post 'verify_pins', to: 'verify_pins#verify'
  get "client_certificates/import_p12", to: "client_certificates#import_p12",
      as: "import_p12_client_certificate"
  resources :client_certificates
  resources :workplaces do
    collection do
      get :new_import
      post :import
      delete :delete_outdated
    end
  end
  resources :networks
  resources :notes, only: [:show, :index, :edit, :update, :destroy] do
    collection do
      get :sindex
    end
  end
  resources :logs, only: [:show, :index, :update, :destroy] do
    collection do
      get :sindex
      put :invalidate_outdated
      delete :delete_outdated
    end
    resources :notes, module: :logs
  end
  get "search", to: 'searches#index'
  resources :operational_states
  resources :cards do
    resources :logs, only: [:index, :show, :destroy], module: :cards
    collection do
      get :sindex
    end
    member do
      get :copy
      post :get_certificate
      post :get_pin_status
      post :verify_pin
      post :get_card
    end
    resources :notes, module: :cards
  end

  post "card_terminals", to: "card_terminals#index", 
                         constraints: lambda {|req| req.format == :json}
  resources :card_terminals do
    resources :logs, only: [:index, :show, :destroy], module: :card_terminals
    collection do
      get :sindex
    end
    member do
      get :ping
      post :check
      post :fetch_idle_message
      get :edit_idle_message
      put :update_idle_message
      post :reboot
      post :remote_pairing
    end
    resources :notes, module: :card_terminals
    resource :kt_proxy, module: :card_terminals
  end
  resources :contexts
  resources :connectors do
    resources :logs, only: [:index, :show, :destroy], module: :connectors
    collection do
      get :sindex
    end
    member do
      post :fetch_sds
      post :get_resource_information
      post :get_card_terminals
      post :get_cards
      get :ping
      post :check
      post :reboot
    end
    resources :notes, module: :connectors
    resource :ti_client, module: :connectors
  end
  resources :locations do
    resources :connectors, only: [:index, :show, :destroy], module: :locations
    resources :card_terminals, only: [:index, :show, :destroy], module: :locations
    resources :cards, only: [:index, :show, :destroy], module: :locations
  end
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
