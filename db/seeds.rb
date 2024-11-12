# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# db/seeds.rb

User.create!(
  email: 'admin@quicket.app',
  password: '123321',
  password_confirmation: '123321',
  role: :admin,
  confirmed_at: Time.current
)

User.create!(
  email: 'user@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :regular,
  confirmed_at: Time.current
)
