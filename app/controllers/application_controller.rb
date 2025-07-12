class ApplicationController < ActionController::API
    before_action :authorize_request
  
    attr_reader :current_user
  
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
  end
  