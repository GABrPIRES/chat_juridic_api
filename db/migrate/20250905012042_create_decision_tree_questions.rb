class CreateDecisionTreeQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :decision_tree_questions do |t|
      t.text :content
      # Adicione default e null: false
      t.boolean :is_root, default: false, null: false

      t.timestamps
    end
  end
end