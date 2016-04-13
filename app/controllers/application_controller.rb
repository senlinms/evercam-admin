class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :check_env

  def authorize_admin
    redirect_to no_access_path if current_user.present? && !current_user.is_admin?
  end

  def connect_intercom
    intercom = Intercom::Client.new(app_id: ENV["INTERCOM_ID"], api_key: ENV["INTERCOM_KEY"])
  end

  def check_env
    if Rails.env.development?
      "http://localhost:3000"
    else
      "https://dash.evercam.io"
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.permit(:firstname, :lastname, :username, :email, :password)
    end
  end

  private

  def render_error(exception)
    render :file => "#{Rails.root}/public/500.html", :layout => false, :status => 500
    notify_airbrake(exception)
  end
end
