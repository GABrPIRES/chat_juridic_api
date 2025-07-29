class ClientSessionsController < ApplicationController
    # Não exige autenticação prévia para login
    skip_before_action :authorize_request
  
    def create
      client = Client.find_by(email: params[:email])
  
      if client && client.authenticate(params[:password])
        token = JwtClientService.encode(client_id: client.id)
        render json: { token: token }, status: :ok
      else
        render json: { error: "E-mail ou senha inválidos" }, status: :unauthorized
      end
    end
  end
  
