class ApplicationController < ActionController::API
    before_action :authorize_request
  
    attr_reader :current_user
    attr_reader :current_client
  
    private
  
    def authorize_request
      header = request.headers['Authorization']
      token = header.split(' ').last if header
  
      begin
        decoded = JwtService.decode(token)
        @current_user = User.find(decoded["user_id"])
      rescue ActiveRecord::RecordNotFound, JWT::DecodeError
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def authorize_client_request
        header = request.headers['Authorization']
        token = header.split(' ').last if header
      
        begin
          decoded = JwtClientService.decode(token)
          @current_client = Client.find(decoded["client_id"])
        rescue ActiveRecord::RecordNotFound, JWT::DecodeError
          render json: { error: "Token inválido ou não autorizado (cliente)" }, status: :unauthorized
        end
    end
      
  end
  