Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  scope :user do
    post "/signup", to: "users#create"
    post "/login", to: "sessions#create"
    get "/me", to: "protected#index"
  end

  # Clientes
  scope :client do
    post "/signup", to: "clients#create"
    post "/login", to: "client_sessions#create"
    get  "/me", to: "clients#show"
  end

  resources :chats do
    resources :messages, only: [:create]
  end

  resources :client_assignments, only: [:create, :destroy]

  # Defines the root path route ("/")
  # root "posts#index"
end
