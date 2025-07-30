class ApplicationController < ActionController::API
  before_action :authorize_request

  attr_reader :current_user, :current_client

  private

  def authorize_request
    header = request.headers['Authorization']
    token = header&.split(' ')&.last
  
    if token.blank?
      render json: { error: "Token ausente" }, status: :unauthorized and return
    end
  
    # Tenta decodificar como User
    begin
      decoded_user = JwtService.decode(token)
      if decoded_user && decoded_user["user_id"]
        @current_user = User.find_by(id: decoded_user["user_id"])
        return if @current_user
      end
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      # Segue para tentar como client
    end
  
    # Tenta decodificar como Client
    begin
      decoded_client = JwtClientService.decode(token)
      if decoded_client && decoded_client["client_id"]
        @current_client = Client.find_by(id: decoded_client["client_id"])
        return if @current_client
      end
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      # Erro final abaixo
    end
  
    render json: { error: "Unauthorized" }, status: :unauthorized
  end
  
end
  