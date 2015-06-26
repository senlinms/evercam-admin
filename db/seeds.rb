@user = User.create!(
  firstname: 'Pedro',
  lastname: 'Brudnix',
  username: 'admin',
  password: 'password1',
  email: 'email1@evercam.io',
  api_id: '7168504232c9cbaf57c5f',
  api_key: 'd46c9f9ca22451c6670f2435c9235cb',
  is_admin: true
)

Camera.create!(
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