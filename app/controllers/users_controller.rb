class UsersController < ApplicationController
    before_action :authorize_create_user, only: [:create]
  
    def create
      user = User.new(user_params)
  
      if user.save
        token = JwtService.encode(user_id: user.id)
        render json: { token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def user_params
      params.require(:user).permit(:name, :email, :phone, :password, :password_confirmation, :role)
    end
  
    def authorize_create_user
      creator = current_user
      role_param = params[:user][:role]
  
      if creator.admin?
        return true
      elsif creator.gerente? && %w[assistente cliente].include?(role_param)
        return true
      else
        render json: { error: "Permissão negada" }, status: :unauthorized
      end
    end
  end
  