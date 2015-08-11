@user = User.create(
  firstname: 'Super',
  lastname: 'Admin',
  username: 'admin',
  password: ENV['ADMIN_PASSWORD'],
  email: ENV['ADMIN_EMAIL'],
  api_id: ENV['ADMIN_API_ID'],
  api_key: ENV['ADMIN_API_KEY'],
  is_admin: true
)
