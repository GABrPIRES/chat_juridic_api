class User < ApplicationRecord
    has_secure_password
    has_many :client_assignments
    has_many :assigned_clients, through: :client_assignments, source: :client


    # Lista de roles válidas
    ROLES = %w[admin gerente assistente].freeze

    # Validação
    validates :role, presence: true, inclusion: { in: ROLES }
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :phone, presence: true
    
    def admin?
        role == "admin"
    end

    def gerente?
        role == "gerente"
    end

    def assistente?
        role == "assistente"
    end
end
