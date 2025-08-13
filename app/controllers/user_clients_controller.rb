class UserClientsController < ApplicationController
    before_action :require_user!
  
    # GET /api/user/clients
    def index
      clients = visible_clients.order(:id)
      render json: clients, status: :ok
    end
  
    # GET /api/user/clients/:id
    def show
      client = find_visible_client!(params[:id])
      render json: client, status: :ok
    end
  
    private
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def visible_clients
      if current_user.admin? || current_user.gerente?
        Client.all
      else
        # assistente: apenas clientes atribuídos
        Client.joins(:client_assignments)
              .where(client_assignments: { user_id: current_user.id })
              .distinct
      end
    end
  
    def find_visible_client!(id)
      if current_user.admin? || current_user.gerente?
        Client.find(id)
      else
        Client.joins(:client_assignments)
              .where(id: id, client_assignments: { user_id: current_user.id })
              .first! # 404 se não encontrar/sem permissão
      end
    end
  end
  