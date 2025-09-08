# config/routes.rb
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  
  scope :api do
    # Auth
    post "user/signup",   to: "users#create"
    post "user/login",    to: "user_sessions#create"
    post "client/signup", to: "clients#create"        # já cria os 2 chats
    post "client/login",  to: "client_sessions#create"

    # Me
    get  "user/me",   to: "users#show"
    get  "users",     to: "users#index"
    delete "users/:id", to: "users#destroy", constraints: { id: /\d+/ }
    get  "client/me", to: "clients#show"

    patch "clients/:id/status", to: "clients#update_status", constraints: { id: /\d+/ }
    patch "user/roles/:id", to: "user_roles#update", constraints: { id: /\d+/ }

    # Profile Management
    get "profile", to: "profiles#show"     # <-- ADICIONE ESTA LINHA
    patch "profile", to: "profiles#update"   # <-- ADICIONE ESTA LINHA

    # User Management
    get "users", to: "users#index"

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
    patch  "user/client_assignments/:id/toggle_reply", to: "user_client_assignments#toggle_reply", constraints: { id: /\d+/ }
   
    # Decision Tree Management
    get "decision_tree", to: "decision_tree#index"
    get "decision_tree/root", to: "decision_tree#root"
    get "decision_tree/questions/:id", to: "decision_tree#show_question"
    post "decision_tree/questions", to: "decision_tree#create"
    post "decision_tree/questions/:question_id/options", to: "decision_tree#create_option"
    patch "decision_tree/options/:id", to: "decision_tree#update_option"

    mount ActionCable.server => '/cable'
  end
end
