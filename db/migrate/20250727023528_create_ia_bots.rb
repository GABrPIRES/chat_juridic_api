class CreateIaBots < ActiveRecord::Migration[8.0]
  def change
    create_table :ia_bots do |t|
      t.string :name
      t.string :description

      t.timestamps
    end
  end
end
