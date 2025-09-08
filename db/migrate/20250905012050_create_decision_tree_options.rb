class CreateDecisionTreeOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :decision_tree_options do |t|
      t.string :content
      t.references :decision_tree_question, null: false, foreign_key: true
      
      # Ajuste a linha abaixo para adicionar a chave estrangeira corretamente
      t.references :next_question, null: true, foreign_key: { to_table: :decision_tree_questions }

      t.timestamps
    end
  end
end