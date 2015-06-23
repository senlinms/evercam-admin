class DashboardController < ActionController::Base
  layout 'admin'

  def index
    @users = User.all.includes(:country, :cameras)
    @cameras = Camera.all.includes(:owner, vendor_model: [:vendor])
    @new_users = @users.where('created_at >= ?', 1.month.ago)
    @new_cameras = @cameras.where('created_at >= ?', 1.month.ago)
  end

  def map
    @cameras = Camera.where.not(location: nil)
  end

  def kpi
  end
end
