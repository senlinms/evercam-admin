class OnvifController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.where(owner_id: 13959).order("name")
    owner_api_id = @cameras.first.user.api_id
    owner_api_key = @cameras.first.user.api_key
    @evercam_server = evercam_server
    @set_cameras = ["Select Camera", ""]
    @cameras.each do |camera|
      external_host = camera.config.deep_fetch("external_host") { "" }
      http_port = camera.config.deep_fetch("external_http_port") { "" }
      username = camera.config.deep_fetch("auth", "basic", "username") { "" }
      password = camera.config.deep_fetch("auth", "basic", "password") { "" }
      @set_cameras[@set_cameras.length] = [camera.name,
        "url=http://#{external_host}:#{http_port}&auth=#{username}:#{password}&api_id=#{owner_api_id}&api_key=#{owner_api_key}"
      ]
    end
    @set_cameras
  end
end
