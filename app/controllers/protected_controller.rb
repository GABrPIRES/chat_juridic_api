class ProtectedController < ApplicationController
    def index
      render json: { message: "Autenticado como #{current_user.name}" }
    end
  end
  