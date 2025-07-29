class Message < ApplicationRecord
  belongs_to :chat
  belongs_to :sender, polymorphic: true

  validates :content, presence: true
end
