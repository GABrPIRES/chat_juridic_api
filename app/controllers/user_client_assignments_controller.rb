class UserClientAssignmentsController < ApplicationController
    before_action :require_user!
    before_action :require_admin_or_gerente!, only: [:create, :destroy]
  
    # GET /api/user/client_assignments
    # admin/gerente: lista todos
    # assistente: lista apenas seus próprios vínculos
    def index
      assignments = if current_user.admin? || current_user.gerente?
                      ClientAssignment
                        .includes(:user, :client)
                        .order(:id)
                    else
                      ClientAssignment
                        .includes(:user, :client)
                        .where(user_id: current_user.id)
                        .order(:id)
                    end
  
      render json: assignments.as_json(
        only: [:id, :user_id, :client_id, :created_at],
        include: {
          user:   { only: [:id, :name, :email, :role] },
          client: { only: [:id, :name, :email] }
        }
      ), status: :ok
    end
  
    # POST /api/user/client_assignments
    # Body: { "client_assignment": { "user_id": 7, "client_id": 42 } }
    def create
      assignment = ClientAssignment.find_or_initialize_by(assignment_params)
  
      if assignment.persisted?
        render json: assignment, status: :ok
      else
        if assignment.save
          render json: assignment, status: :created
        else
          render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
        end
      end
    end
  
    # DELETE /api/user/client_assignments/:id
    def destroy
      assignment = ClientAssignment.find(params[:id])
      assignment.destroy
      head :no_content
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Assignment não encontrado" }, status: :not_found
    end
  
    private
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def require_admin_or_gerente!
      allowed = current_user&.admin? || current_user&.gerente?
      render json: { error: "Permissão negada" }, status: :forbidden and return unless allowed
    end
  
    def assignment_params
      params.require(:client_assignment).permit(:user_id, :client_id)
    end
  end
  