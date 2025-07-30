class ClientsController < ApplicationController
    before_action :authorize_create_client, only: [:create]
  
    def create
      client = Client.new(client_params)
    
      if client.save
        # Cria os dois chats automaticamente
        Chat.create!(client: client, chat_type: "cliente")
        Chat.create!(client: client, chat_type: "ia")
    
        token = JwtClientService.encode(client_id: client.id)
        render json: { token: token }, status: :created
      else
        render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
      end
    end
    

    def show
      render json: { name: @current_client.name, email: @current_client.email }
    end
  
    private
  
    def client_params
      params.require(:client).permit(:name, :email, :phone, :password, :password_confirmation)
    end
  
    def authorize_create_client
      creator = current_user
  
      if creator.admin?
        return true
      elsif creator.gerente?
        return true
      else
        render json: { error: "Permissão negada" }, status: :unauthorized
      end
    end
  end
  