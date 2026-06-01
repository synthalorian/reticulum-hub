Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # PWA routes
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Root
  root "dashboard#index"

  # Dashboard
  get "dashboard", to: "dashboard#index"

  # Messages (LXMF)
  resources :messages, only: [:index, :show, :new, :create]

  # Interfaces
  resources :interfaces, only: [:index, :show, :edit, :update] do
    member do
      post :enable
      post :disable
      post :restart
    end
  end

  # Network Explorer
  resources :explorer, only: [:index, :show]

  # Alerts
  resources :alerts, only: [:index, :show] do
    member do
      post :acknowledge
      post :resolve
    end
  end

  # Announces
  resources :announces, only: [:index, :create]

  # Settings
  get "settings", to: "settings#index"
  patch "settings", to: "settings#update"

  # Config
  resources :configs, only: [:index] do
    collection do
      get :export
      post :import
    end
  end

  # Multi-node
  resources :multi_nodes, only: [:index, :show]

  # Logs
  resources :logs, only: [:index] do
    collection do
      get :stream
      delete :clear
    end
  end
  # Health
  get "health", to: "health#index"
  get "health/check", to: "health#check"

  # Retention
  resources :retention, only: [:index] do
    collection do
      post :cleanup
    end
  end

  # API Tokens
  resources :api_tokens, only: [:index, :create, :destroy]

  # Backups
  resources :backups, only: [:index, :create, :destroy] do
    collection do
      post :restore
      get :download
    end
  end

  # Maps
  resources :maps, only: [:index]

  # Metrics
  resources :metrics, only: [:index] do
    collection do
      get :peer
      get :interface
    end
  end

  # API namespace for AJAX / WebSocket fallback
  namespace :api do
    get "status", to: "status#index"
    get "peers", to: "status#peers"
    get "interfaces", to: "status#interfaces"
    get "stats", to: "status#stats"
  end
end
