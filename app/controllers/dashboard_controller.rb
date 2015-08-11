class DashboardController < ApplicationController
  before_action :authorize_admin

  def index
    @users = EvercamUser.all.includes(:country, :cameras)
    @cameras = Camera.all.includes(:user, vendor_model: [:vendor])
    @new_users = @users.where('created_at >= ?', 1.month.ago).decorate
    @new_cameras = @cameras.where('created_at >= ?', 1.month.ago).decorate
  end

  def map
    @cameras = Camera.where.not(location: nil)
  end

  def kpi
  end
end
