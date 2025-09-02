class UsersController < ApplicationController
    before_action :authorize_create_user, only: [:create]
    before_action :require_user!, only: [:index, :show, :destroy] # Protege a nova rota
    before_action :require_admin!, only: [:index, :destroy]      # Apenas admins podem listar todos os usuários

    # GET /api/users
    def index
      # Busca todos os usuários que não são clientes e ordena por ID
      users = User.order(:id) 
      render json: users.as_json(only: %i[id name email role]), status: :ok
    end

    def create
      user = User.new(user_params)
  
      if user.save
        token = JwtService.encode(user_id: user.id)
        render json: { token: token }, status: :created
      else
        render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def show
      if current_user
        render json: current_user.as_json(only: %i[id name email role]), status: :ok
      else
        render json: { error: "Unauthorized" }, status: :unauthorized
      end
    end

    def destroy
      target_user = User.find(params[:id])
  
      # Regra de segurança: Admin não pode se auto-excluir nem excluir outro admin.
      if current_user.id == target_user.id || target_user.admin?
        return render json: { error: "Permissão negada para excluir este usuário" }, status: :forbidden
      end
  
      target_user.destroy
      head :no_content # Retorna uma resposta 204 No Content, indicando sucesso sem corpo.
    
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end  
  
    private

    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def require_admin!
      render json: { error: "Permissão negada" }, status: :forbidden and return unless current_user.admin?
    end
  
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
  