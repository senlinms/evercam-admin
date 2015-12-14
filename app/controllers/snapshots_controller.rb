class SnapshotsController < ApplicationController
  before_action :authorize_admin

  def index
    @cameras = Camera.all.includes(:user)
  end
end