class AddCanReplyToClientToClientAssignments < ActiveRecord::Migration[8.0]
  def change
    add_column :client_assignments, :can_reply_to_client, :boolean, default: false, null: false
  end
end