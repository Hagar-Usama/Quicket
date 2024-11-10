class Ticket < ApplicationRecord
  belongs_to :user, optional: true

  # Soft delete functionality (optional)
  default_scope { where(deleted_at: nil) }

  def soft_delete
    update(deleted_at: Time.current)
  end
end
