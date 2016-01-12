class DashboardController < ApplicationController
  before_action :authorize_admin

  def index
    @users = EvercamUser.all #.includes(:country, :cameras)
    # @cameras = Camera.all.includes(:user, vendor_model: [:vendor])
    @cameras = Camera.all
    @new_users = EvercamUser.where('created_at >= ?', 1.month.ago).all
    @new_cameras = Camera.where('created_at >= ?', 1.month.ago).all
  end

  def map
    @cameras = Camera.where.not(location: nil)
  end

  def kpi
  end
end
