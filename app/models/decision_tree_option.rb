class DecisionTreeQuestion < ApplicationRecord
  has_many :options, class_name: 'DecisionTreeOption', dependent: :destroy
  
  validates :content, presence: true
end