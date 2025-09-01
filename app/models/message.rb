class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :sender, polymorphic: true
  after_create_commit :broadcast!

  validates :content, presence: true

  private
  def broadcast!
    Rails.logger.info("[Cable] broadcast chat=#{chat_id} msg=#{id}")
    ActionCable.server.broadcast("chat_#{chat_id}", {
      id: id, chat_id: chat_id, content: content,
      sender_type: sender_type, created_at: created_at.iso8601
    })
  end
  
end
