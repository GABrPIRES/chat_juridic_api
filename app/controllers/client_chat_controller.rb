class ClientChatController < ApplicationController
    before_action :require_client!
    before_action :set_client_chat!
  
    # GET /api/client/chat
    def show
      msgs = @chat.messages.order(:created_at)
      render json: msgs.as_json(only: %i[id chat_id content sender_type created_at]), status: :ok
    end
  
    # POST /api/client/chat
    def create
      content = params.require(:message).permit(:content)[:content]
  
      msg = @chat.messages.create!(
        content:     content,
        sender_type: 'Client',
        sender_id:   current_client.id
      )
  
      payload = msg.as_json(only: %i[id chat_id content sender_type created_at])
  
      # 🔧 mesmo nome de stream
      ActionCable.server.broadcast("chats:#{@chat.id}", payload)
  
      render json: payload, status: :created
    end
  
    private
  
    def require_client!
      render json: { error: 'Unauthorized' }, status: :unauthorized and return unless current_client
    end
  
    def set_client_chat!
      @chat = Chat.find_by!(client_id: current_client.id, chat_type: 'cliente')
    end
  end
  