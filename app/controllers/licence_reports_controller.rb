class LicenceReportsController < ApplicationController
  before_action :authorize_admin
  require "stripe"

  def index
    begin
      if params[:save]
        @licence = Licence.new(
            user_id: params["user_id"],
            description: params["licence_desc"],
            total_cameras: params["total_cameras"],
            storage: params["storage"],
            amount: params["amount"],
            start_date: DateTime.parse(params["start_date"]),
            end_date: DateTime.parse(params["end_date"]),
            created_at: Time.now
        )
        respond_to do |format|
          if @licence.save
            format.html { redirect_to vendors_path, notice: 'Licence successfully created' }
            format.json { render json: @licence }
          else
            format.html { redirect_to vendors_path }
            format.json { render json: @licence.errors.full_messages, status: :unprocessable_entity }
          end
        end
        # render json: []
      else
        @customers = Stripe::Customer.all(limit: 200)
        @custom_licences = Licence.all
        @users = EvercamUser.all
      end
    rescue => error
      notify_airbrake(error)
    end
  end
end
