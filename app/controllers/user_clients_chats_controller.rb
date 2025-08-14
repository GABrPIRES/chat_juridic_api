class UserClientsChatsController < ApplicationController
    before_action :require_user!
  
    # GET /api/user/clients/chats
    # GET /api/user/clients/:client_id/chats
    def index
      if params[:client_id].present?
        client = find_visible_client!(params[:client_id])
        chats = client.chats.order(:id)
      else
        chats = visible_chats_for_user.order(:id)
      end
  
      render json: chats, status: :ok
    end
  
    # GET /api/user/clients/:client_id/chats/:id
    def show
      client = find_visible_client!(params[:client_id])
      chat   = client.chats.find(params[:id])
      render json: chat, status: :ok
    end
  
    # 🔹 NOVO: GET /api/user/clients/:client_id/chats/:id/messages
    # Lista as mensagens do chat, respeitando as permissões do user
    def messages
      client = find_visible_client!(params[:client_id])
      chat   = client.chats.find(params[:id])
  
      msgs = chat.messages.order(:created_at)
      render json: msgs, status: :ok
    end
  
    # POST /api/user/clients/:client_id/chats/:id/messages
    # Body: { "message": { "content": "texto..." } }
    def create
      client = find_visible_client!(params[:client_id])
      chat   = client.chats.find(params[:id])
  
      unless can_post_in_client?(client.id)
        render json: { error: "Permissão negada" }, status: :forbidden and return
      end
  
      message = chat.messages.build(message_params)
      message.sender = current_user  # polimórfico: User como remetente
  
      if message.save
        render json: message, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    # Clientes visíveis ao current_user
    def visible_clients_relation
      if current_user.admin? || current_user.gerente?
        Client.all
      else
        Client.joins(:client_assignments)
              .where(client_assignments: { user_id: current_user.id })
              .distinct
      end
    end
  
    # Chats visíveis ao current_user
    def visible_chats_for_user
      if current_user.admin? || current_user.gerente?
        Chat.all
      else
        Chat.joins(client: :client_assignments)
            .where(client_assignments: { user_id: current_user.id })
            .distinct
      end
    end
  
    # Busca cliente respeitando visibilidade
    def find_visible_client!(id)
      if current_user.admin? || current_user.gerente?
        Client.find(id)
      else
        Client.joins(:client_assignments)
              .where(id: id, client_assignments: { user_id: current_user.id })
              .first! # 404 se não for visível
      end
    end
  
    # Admin/Gerente sempre podem postar; Assistente só se atribuído ao client
    def can_post_in_client?(client_id)
      return true if current_user.admin? || current_user.gerente?
      ClientAssignment.exists?(user_id: current_user.id, client_id: client_id)
    end
  
    def message_params
      params.require(:message).permit(:content)
    end
  end
  