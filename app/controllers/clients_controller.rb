class ClientsController < ApplicationController
    before_action :authorize_create_client, only: [:create]
    before_action :require_user!, only: [:update_status]
    before_action :require_admin_or_gerente!, only: [:update_status]
  
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

    def update_status
      client = Client.find(params[:id])
      new_status = params.require(:client).permit(:status)[:status]

      unless Client::STATUSES.include?(new_status)
        return render json: { error: "Status inválido" }, status: :unprocessable_entity
      end

      if client.update(status: new_status)
        render json: client.as_json(only: %i[id name email phone status]), status: :ok
      else
        render json: { errors: client.errors.full_messages }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Cliente não encontrado" }, status: :not_found
    end
  
    private

    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def require_admin_or_gerente!
      allowed = current_user.admin? || current_user.gerente?
      render json: { error: "Permissão negada" }, status: :forbidden and return unless allowed
    end
  
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
  