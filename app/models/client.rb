class Client < ApplicationRecord
    has_secure_password
  
    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
    validates :phone, presence: true

    has_many :chats, dependent: :destroy
    has_many :messages, through: :chat
    has_many :client_assignments
    has_many :assigned_users, through: :client_assignments, source: :user
  end
  