class AddStatusToChats < ActiveRecord::Migration[8.0]
  def change
    # Adicione :default e :null
    add_column :chats, :status, :string, default: 'pending_tree', null: false
  end
end