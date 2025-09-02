# app/controllers/user_roles_controller.rb
class UserRolesController < ApplicationController
    before_action :require_user!
    before_action :require_admin! # Apenas Admins podem alterar roles por segurança
    before_action :set_target_user
  
    # PATCH /api/user/roles/:id
    def update
      new_role = params.require(:user).permit(:role)[:role]
  
      unless User::ROLES.include?(new_role)
        return render json: { error: "Cargo inválido" }, status: :unprocessable_entity
      end
  
      # Aplica as regras da matriz de permissão
      unless can_assign_role?(current_user, @target_user, new_role)
        return render json: { error: "Permissão negada para esta ação" }, status: :forbidden
      end
  
      if @target_user.update(role: new_role)
        render json: @target_user.as_json(only: %i[id name email role]), status: :ok
      else
        render json: { errors: @target_user.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    private
  
    def set_target_user
      @target_user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Usuário não encontrado" }, status: :not_found
    end
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    # Apenas Admins podem acessar este controller
    def require_admin!
      render json: { error: "Permissão negada" }, status: :forbidden and return unless current_user.admin?
    end
  
    # Lógica central de permissão para mudança de cargo
    def can_assign_role?(assigner, target_user, new_role)
      # Regra: Ninguém pode alterar o próprio cargo por esta rota.
      return false if assigner.id == target_user.id
      
      # Regra: Admin pode alterar qualquer cargo, exceto de outros admins para evitar conflitos.
      # Se você quiser que um admin possa rebaixar outro, remova a condição '!target_user.admin?'.
      if assigner.admin?
        return !target_user.admin?
      end
  
      # Outras roles não podem usar esta rota (já bloqueado por require_admin!)
      false
    end
  end