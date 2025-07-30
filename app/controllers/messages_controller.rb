class MessagesController < ApplicationController
    before_action :authenticate_sender!
    before_action :set_chat
    before_action :authorize_sender!
  
    def create
        Rails.logger.debug(params.inspect)
      @message = @chat.messages.build(message_params)
      @message.sender = current_sender
  
      if @message.save
        render json: @message, status: :created
      else
        render json: { errors: @message.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def index
        @chat = Chat.find(params[:chat_id])
        authorize_view!
      
        messages = @chat.messages.order(:created_at)
        render json: messages
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

    def authorize_view!
        Rails.logger.debug("current_user: #{current_user&.role}")
        Rails.logger.debug("current_client: #{current_client.inspect}")
        if current_client
            Rails.logger.debug(current_client.inspect)
            Rails.logger.debug(@chat.client_id.inspect)
            Rails.logger.debug(@chat.chat_type.inspect)
            if @chat.client_id != current_client.id
                render json: { error: "Acesso negado - outro cliente" }, status: :forbidden
            elsif @chat.chat_type != "cliente"
                render json: { error: "Acesso negado - chat exclusivo da IA" }, status: :forbidden
            end                       
        elsif current_user
          case current_user.role
          when "admin", "gerente"
            # acesso liberado
            return
          when "assistente"
            assigned = ClientAssignment.exists?(user_id: current_user.id, client_id: @chat.client_id)
            unless assigned
              render json: { error: "Acesso negado - cliente não atribuído" }, status: :forbidden
            end
          else
            render json: { error: "Role inválida" }, status: :forbidden
          end
        else
          render json: { error: "Não autenticado" }, status: :unauthorized
        end
    end      
  
    def message_params
      params.require(:message).permit(:content)
    end
  end
  