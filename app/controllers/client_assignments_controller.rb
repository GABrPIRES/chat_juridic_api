class ClientAssignmentsController < ApplicationController
  before_action :authorize_user_assignment

  def create
    assignment = ClientAssignment.new(assignment_params)

    if assignment.save
      render json: { message: "Cliente atribuído com sucesso." }, status: :created
    else
      render json: { errors: assignment.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    assignment = ClientAssignment.find_by(assignment_params)

    if assignment&.destroy
      render json: { message: "Cliente desatribuído com sucesso." }, status: :ok
    else
      render json: { error: "Associação não encontrada" }, status: :not_found
    end
  end

  private

  def assignment_params
    params.require(:client_assignment).permit(:user_id, :client_id)
  end

  def authorize_user_assignment
    unless current_user&.admin? || current_user&.gerente?
      render json: { error: "Permissão negada" }, status: :unauthorized
    end
  end
end
