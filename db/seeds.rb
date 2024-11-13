# db/seeds.rb

User.create!(
  email: 'admin@quicket.app',
  password: '123321',
  password_confirmation: '123321',
  role: :admin,
  confirmed_at: Time.current
)
