class ClientChatController < ApplicationController
    before_action :require_client!
    before_action :set_client_chat!
  
    # GET /api/client/chat
    def show
      messages = @chat.messages.order(:created_at)
      render json: messages, status: :ok
    end
  
    # POST /api/client/chat
    def create
      message = @chat.messages.build(message_params)
      message.sender = current_client
  
      if message.save
        render json: message, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def require_client!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_client
    end
  
    def set_client_chat!
      @chat = Chat.find_by(client_id: current_client.id, chat_type: "cliente")
      render json: { error: "Chat não encontrado" }, status: :not_found and return unless @chat
    end
  
    def message_params
      params.require(:message).permit(:content)
    end
  end
  