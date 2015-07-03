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

Camera.create(
  exid: "exid1",
  user_id: @user.id,
  is_public: true,
  config: {"snapshots"=>{"jpg"=>"/onvif/snapshot"}, "auth"=>{"basic"=>{"username"=>"abcd", "password"=>"wxyz"}},
           "external_host"=>"www.evercam.test", "external_http_port"=>80},
  name: "name1",
  last_polled_at: nil,
  is_online: true,
  mac_address: "c8:f7:33:ca:4f:ea",
  discoverable: true
)