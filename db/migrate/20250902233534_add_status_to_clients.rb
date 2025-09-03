class AddStatusToClients < ActiveRecord::Migration[8.0]
  def change
    add_column :clients, :status, :string, default: 'active', null: false
  end
end