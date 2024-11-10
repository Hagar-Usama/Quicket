class ChangeUserIdNullInTickets < ActiveRecord::Migration[7.2]
  def change
    change_column_null :tickets, :user_id, true
  end
end
