class Client < ApplicationRecord
  has_secure_password

  STATUSES = %w[active inactive].freeze
  validates :status, presence: true, inclusion: { in: STATUSES }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone, presence: true

  has_many :chats, dependent: :destroy
  has_many :messages, through: :chats
  has_many :client_assignments
  has_many :assigned_users, through: :client_assignments, source: :user

  def active?
    status == 'active'
  end
end
  