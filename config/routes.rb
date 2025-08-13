# config/routes.rb
Rails.application.routes.draw do
  scope :api do
    # Auth
    post "user/signup",   to: "users#create"
    post "user/login",    to: "user_sessions#create"
    post "client/signup", to: "clients#create"        # já cria os 2 chats
    post "client/login",  to: "client_sessions#create"

    # Me
    get  "user/me",   to: "protected#index"
    get  "client/me", to: "clients#show"

    # Chats & Messages (do jeito que você já tem)
    resources :chats, only: [:show] do
      resources :messages, only: [:index, :create]
    end

    # Chat do cliente (Whats-like)
    get  "client/chat", to: "client_chat#show"
    post "client/chat", to: "client_chat#create"

    # Área de usuário (admin/gerente/assistente)
    get  "user/clients",     to: "user_clients#index"
    get  "user/clients/:id", to: "user_clients#show"
  end
end
