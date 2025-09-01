class UserClientsChatsController < ApplicationController
    before_action :require_user!
  
    # GET /api/user/clients/:client_id/chats
    def index
      client = find_visible_client!(params[:client_id])
      render json: client.chats.order(:id), status: :ok
    end
  
    # GET /api/user/clients/:client_id/chats/:id/messages
    def messages
      client = find_visible_client!(params[:client_id])
      chat   = client.chats.find(params[:id])
  
      msgs = chat.messages.order(:created_at)
      render json: msgs.as_json(only: %i[id chat_id content sender_type created_at]), status: :ok
    end
  
    # POST /api/user/clients/:client_id/chats/:id/messages
    def create
      client = find_visible_client!(params[:client_id])
      chat   = client.chats.find(params[:id])
  
      # só permitimos content; o sender vem do backend
      content = params.require(:message).permit(:content)[:content]
  
      msg = chat.messages.create!(
        content:     content,
        sender_type: 'User',
        sender_id:   current_user.id
      )
  
      payload = msg.as_json(only: %i[id chat_id content sender_type created_at])
  
      # 🔧 stream e broadcast com o MESMO nome
      ActionCable.server.broadcast("chats:#{chat.id}", payload)
  
      render json: payload, status: :created
    end
  
    private
  
    def require_user!
      render json: { error: 'Unauthorized' }, status: :unauthorized and return unless current_user
    end
  
    def visible_clients
      if current_user.admin? || current_user.gerente?
        Client.all
      else
        Client.joins(:client_assignments)
              .where(client_assignments: { user_id: current_user.id })
              .distinct
      end
    end
  
    def find_visible_client!(id)
      if current_user.admin? || current_user.gerente?
        Client.find(id)
      else
        Client.joins(:client_assignments)
              .where(id: id, client_assignments: { user_id: current_user.id })
              .first! # 404 se não tiver acesso
      end
    end
  end
  