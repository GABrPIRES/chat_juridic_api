class DecisionTreeOption < ApplicationRecord
  belongs_to :decision_tree_question
  belongs_to :next_question, class_name: 'DecisionTreeQuestion', optional: true

  validates :content, presence: true
end