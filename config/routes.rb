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

    # Chat do cliente (Whats-like)
    get  "client/chat", to: "client_chat#show"
    post "client/chat", to: "client_chat#create"

    get "user/clients/chats",             to: "user_clients_chats#index"      # <= específica primeiro
    get "user/clients/:client_id/chats",  to: "user_clients_chats#index"      # <= específica
    get "user/clients/:client_id/chats/:id", to: "user_clients_chats#show"    # <= específica
    get  "user/clients/:client_id/chats/:id/messages",to: "user_clients_chats#messages", constraints: { client_id: /\d+/, id: /\d+/ }
    post "user/clients/:client_id/chats/:id/messages", to: "user_clients_chats#create", constraints: { client_id: /\d+/, id: /\d+/ }

    get "user/clients",     to: "user_clients#index"
    get "user/clients/client/:id", to: "user_clients#show"

    get    "user/client_assignments",          to: "user_client_assignments#index"
    post   "user/client_assignments",          to: "user_client_assignments#create"
    delete "user/client_assignments/:id",      to: "user_client_assignments#destroy", constraints: { id: /\d+/ }
  end
end
