class ClientChatController < ApplicationController
    before_action :require_client!
    before_action :set_client_chat!
  
    # GET /api/client/chat
    def show
        msgs = @chat.messages.order(:created_at)
        
        render json: {
        chat_id: @chat.id,
        status: @chat.status, # <-- ADICIONE ESTA LINHA
        messages: msgs.as_json(only: %i[id chat_id content sender_type created_at])
        }, status: :ok
    end
  
    # POST /api/client/chat
    def create
        unless current_client.active?
            return render json: { error: "Sua conta está inativa. Não é possível enviar mensagens." }, status: :forbidden
        end

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

    def submit_tree
        final_content = params.require(:message).permit(:content)[:content]
    
        # Encontra o chat da IA para este cliente
        ia_chat = Chat.find_by!(client_id: current_client.id, chat_type: 'ia')
        
        # Cria a mensagem no chat da IA como se fosse enviada pelo cliente
        ia_message = ia_chat.messages.create!(
          content: final_content,
          sender: current_client # Define o remetente como o próprio cliente
        )
    
        # Muda o status do chat principal do cliente para 'ongoing'
        @chat.update!(status: 'ongoing')
    
        # Cria a mensagem de confirmação no chat do cliente
        confirmation_message = @chat.messages.create!(
          content: "Sua solicitação foi recebida e nossa equipe já está analisando. Você será notificado e poderá acompanhar o andamento por este chat. Obrigado!",
          sender_type: 'IaBot', # Podemos usar o IaBot como remetente
          sender_id: IaBot.first_or_create(name: "Assistente Virtual").id
        )
    
        # Envia a mensagem de confirmação via WebSocket para o cliente
        ActionCable.server.broadcast("chats:#{@chat.id}", confirmation_message.as_json)
    
        # Retorna sucesso
        render json: { success: true }, status: :ok
    end
    
  
    private
  
    def require_client!
      render json: { error: 'Unauthorized' }, status: :unauthorized and return unless current_client
    end
  
    def set_client_chat!
      @chat = Chat.find_by!(client_id: current_client.id, chat_type: 'cliente')
    end
  end
  