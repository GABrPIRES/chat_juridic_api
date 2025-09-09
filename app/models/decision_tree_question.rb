class DecisionTreeQuestion < ApplicationRecord
    has_many :options, class_name: 'DecisionTreeOption', foreign_key: 'decision_tree_question_id', dependent: :destroy
  
    validates :content, presence: true
  end