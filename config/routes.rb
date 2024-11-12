# Rails.application.routes.draw do
# get "users/show"
# get "admin/dashboard"
# get "tickets/index"
# get "tickets/show"
# get "tickets/update"
#   devise_for :users
#   # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

#   # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
#   # Can be used by load balancers and uptime monitors to verify that the app is live.
#   get "up" => "rails/health#show", as: :rails_health_check

#   # Render dynamic PWA files from app/views/pwa/*
#   get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
#   get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

#   # Defines the root path route ("/")
#   # root "posts#index"
# end

# config/routes.rb
Rails.application.routes.draw do
  # Devise routes for user authentication
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  ## Profile route
  authenticate :user do
    get "profile", to: "profile#show", as: :profile
  end

  # Routes for tickets
  resources :tickets, only: [ :index, :show, :update ] do
    collection do
      post :fetch_tickets
      get :ticket_exists
    end

    member do
      put :soft_delete
    end
  end

  # Webhook route
  post "webhooks/tito", to: "webhooks#tito"

  # Root route
  root to: "tickets#index"
end
