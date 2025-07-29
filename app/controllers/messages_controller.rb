class MessagesController < ApplicationController
    before_action :authenticate_sender!
  
    def create
      chat = Chat.find_by(id: params[:chat_id])
      return render json: { error: "Chat não encontrado" }, status: :not_found unless chat
  
      unless authorized_to_send?(chat)
        return render json: { error: "Você não pode enviar mensagem nesse chat" }, status: :unauthorized
      end
  
      message = Message.new(
        chat: chat,
        content: params[:content],
        sender_type: sender_type,
        sender_id: sender_id
      )
  
      if message.save
        render json: message, status: :created
      else
        render json: { errors: message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    # 🔐 Determina quem está autenticado: user ou client
    def authenticate_sender!
      unless current_user || current_client
        render json: { error: "Usuário não autenticado" }, status: :unauthorized
      end
    end
  
    def sender_type
      return "User" if current_user
      return "Client" if current_client
      nil
    end
  
    def sender_id
      return current_user.id if current_user
      return current_client.id if current_client
      nil
    end
  
    # 🔒 Valida se esse sender pode escrever nesse chat
    def authorized_to_send?(chat)
        if sender_type == "Client"
          # Cliente só pode enviar no próprio chat do tipo "cliente"
          return chat.chat_type == "cliente" && chat.client_id == current_client.id
      
        elsif sender_type == "User"
          user = current_user
      
          return true if user.admin? || user.gerente?
      
          if user.assistente?
            # Assistente só pode enviar no chat de IA, e só se tiver acesso ao cliente
            return chat.chat_type == "ia" && user.assigned_clients.exists?(id: chat.client_id)
          end
        end
      
        false
      end      
end
  