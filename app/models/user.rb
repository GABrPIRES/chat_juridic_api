class User < ApplicationRecord
    has_secure_password

    # Lista de roles válidas
    ROLES = %w[admin gerente assistente].freeze

    # Validação
    validates :role, presence: true, inclusion: { in: ROLES }
    
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
