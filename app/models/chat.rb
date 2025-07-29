class Chat < ApplicationRecord
  belongs_to :client
  has_many :messages, dependent: :destroy

  # Lista de tipos válidos
  TYPES = %w[cliente ia].freeze

  # Validações
  validates :chat_type, presence: true, inclusion: { in: TYPES }

  # Métodos de conveniência
  def cliente?
    chat_type == "cliente"
  end

  def ia?
    chat_type == "ia"
  end
end
