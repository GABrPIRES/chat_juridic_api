class CreateMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :messages do |t|
      t.references :chat, null: false, foreign_key: true
      t.string :sender_type
      t.integer :sender_id
      t.text :content
      t.boolean :approved

      t.timestamps
    end
  end
end
