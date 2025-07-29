class MessagesController < ApplicationController
    before_action :authenticate_sender!
    before_action :set_chat
    before_action :authorize_sender!
  
    def create
      @message = @chat.messages.build(message_params)
      @message.sender = current_sender
  
      if @message.save
        render json: @message, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def authenticate_sender!
      unless current_user || current_client
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  
    def current_sender
      current_user || current_client
    end
  
    def set_chat
      @chat = Chat.find(params[:chat_id])
    end
  
    def authorize_sender!
      if current_client
        unless @chat.client_id == current_client.id
          render json: { error: 'Forbidden' }, status: :forbidden
        end
      elsif current_user
        case current_user.role
        when 'admin', 'gerente'
          # acesso total
          return
        when 'assistente'
          client_id = @chat.client_id
          assigned = ClientAssignment.exists?(user_id: current_user.id, client_id: client_id)
          unless assigned
            render json: { error: 'Forbidden - not assigned to this client' }, status: :forbidden
          end
        else
          render json: { error: 'Forbidden - invalid role' }, status: :forbidden
        end
      else
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    end
  
    def message_params
      params.require(:message).permit(:content)
    end
  end
  