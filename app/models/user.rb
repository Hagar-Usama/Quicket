class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable

  enum role: { regular: 0, admin: 1 }

  has_many :tickets, dependent: :destroy

  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= :regular
  end
end
