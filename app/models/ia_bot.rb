class IaBot < ApplicationRecord
    has_many :messages, as: :sender, dependent: :nullify
  
    validates :name, presence: true
end
  