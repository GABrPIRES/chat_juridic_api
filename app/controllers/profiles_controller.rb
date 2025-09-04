# app/controllers/profiles_controller.rb
class ProfilesController < ApplicationController
    before_action :require_user!
  
    # GET /api/profile
    def show
      render json: current_user.as_json(only: %i[id name email]), status: :ok
    end
  
    # PATCH /api/profile
    def update
      # Para atualizar a senha, o usuário deve fornecer a senha atual
      if params[:user][:password].present?
        unless current_user.authenticate(params[:user][:current_password])
          return render json: { errors: ['Senha atual incorreta'] }, status: :unprocessable_entity
        end
      end
  
      if current_user.update(profile_params)
        render json: current_user.as_json(only: %i[id name email]), status: :ok
      else
        render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def profile_params
      # Permite a atualização de nome, email e senha (com confirmação)
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end
  end