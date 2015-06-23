class CamerasController < ActionController::Base
  layout 'admin'

  def index
    @cameras = Camera.all.includes(:user, vendor_model: [:vendor])
  end

  def show
    @camera = Camera.find(params[:id])
  end

end
