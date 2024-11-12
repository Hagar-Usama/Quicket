class ChangeRoleToIntegerInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :role, :integer, default: 0, null: false, using: "CASE WHEN role = 'regular' THEN 0 WHEN role = 'admin' THEN 1 ELSE 0 END"
  end
end
