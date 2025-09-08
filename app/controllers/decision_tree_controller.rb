# app/controllers/decision_tree_controller.rb
class DecisionTreeController < ApplicationController
    # Filtros para rotas de ADMIN (gerenciamento da árvore)
    before_action :require_user!, only: [:index, :create, :create_option, :update_option]
    before_action :require_admin!, only: [:index, :create, :create_option, :update_option]
  
    # Filtros para rotas de CLIENTE (navegação na árvore)
    before_action :require_client!, only: [:root, :show_question]
  
    # GET /api/decision_tree
    def index
      questions = DecisionTreeQuestion.includes(:options).all
      render json: questions.as_json(include: :options)
    end
  
    # GET /api/decision_tree/root
    def root
      root_question = DecisionTreeQuestion.find_by(is_root: true)
      if root_question
        render json: root_question.as_json(include: :options)
      else
        render json: { error: "Nenhuma pergunta inicial foi configurada" }, status: :not_found
      end
    end
  
    # GET /api/decision_tree/questions/:id
    def show_question
      question = DecisionTreeQuestion.find(params[:id])
      render json: question.as_json(include: :options)
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Pergunta não encontrada" }, status: :not_found
    end
  
    # ... (o resto dos métodos create, create_option, update_option)
    def create
      question = DecisionTreeQuestion.new(question_params)
      if question.save
        render json: question.as_json(include: :options), status: :created
      else
        render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def create_option
      question = DecisionTreeQuestion.find(params[:question_id])
      option = question.options.new(option_params)
      if option.save
        render json: option, status: :created
      else
        render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
    def update_option
      option = DecisionTreeOption.find(params[:id])
      if option.update(option_params)
        render json: option, status: :ok
      else
        render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
      end
    end
  
  
    private
  
    def require_user!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_user
    end
  
    def require_admin!
      render json: { error: "Permissão negada" }, status: :forbidden and return unless current_user.admin?
    end
  
    def require_client!
      render json: { error: "Unauthorized" }, status: :unauthorized and return unless current_client
    end
  
    def question_params
      params.require(:question).permit(:content, :is_root)
    end
  
    def option_params
      params.require(:option).permit(:content, :next_question_id)
    end
  end