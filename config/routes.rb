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

  # API namespace for AJAX / WebSocket fallback
  namespace :api do
    get "status", to: "status#index"
    get "peers", to: "status#peers"
    get "interfaces", to: "status#interfaces"
    get "stats", to: "status#stats"
  end
end
