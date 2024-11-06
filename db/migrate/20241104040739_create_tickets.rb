class CreateTickets < ActiveRecord::Migration[7.2]
  def change
    create_table :tickets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :name
      t.string :phone_number
      t.string :state
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
