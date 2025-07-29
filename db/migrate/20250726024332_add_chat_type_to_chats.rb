class AddChatTypeToChats < ActiveRecord::Migration[8.0]
  def change
    add_column :chats, :chat_type, :string
  end
end
