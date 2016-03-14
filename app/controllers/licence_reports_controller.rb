class LicenceReportsController < ApplicationController
  before_action :authorize_admin
  require "stripe"

  def index
    begin
      @customers = Stripe::Customer.all(limit: 200)
      @custom_licences = Licence.where(cancel_licence: false, subscription_id: nil).all
      @users = EvercamUser.all
      if ENV["UPDATE_STRIPE_LICENCES"].eql?("yes")
        add_stripe_licence
      end
    rescue => error
      notify_airbrake(error)
    end
  end

  def create
    begin
      @licence = Licence.new(
        user_id: params["user_id"],
        description: params["licence_desc"],
        total_cameras: params["total_cameras"],
        storage: params["storage"],
        amount: params["amount"].to_i * 100,
        start_date: DateTime.parse(params["start_date"]),
        end_date: DateTime.parse(params["end_date"]),
        paid: params["paid"],
        created_at: Time.now
      )
      respond_to do |format|
        if @licence.save
          format.html { redirect_to licence_report_path, notice: 'Licence successfully created' }
          format.json { render json: @licence.to_json(include: [:user]) }
        else
          format.html { redirect_to licence_report_path }
          format.json { render json: @licence.errors.full_messages, status: :unprocessable_entity }
        end
      end
    rescue => error
      notify_airbrake(error)
      respond_to do |format|
        format.html { redirect_to licence_report_path }
        format.json { render json: error.message, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    begin
      if params[:licence_type] && params[:licence_type].eql?("custom")
        licence = Licence.where(id: params[:subscription_id]).first
        licence.update_attribute(:cancel_licence, true)
        respond_to do |format|
          format.html { redirect_to licence_report_path, notice: "Licence canceled successfully." }
          format.json { render json: [] }
        end
      elsif params[:customer_id] && params[:subscription_id]
        customer = Stripe::Customer.retrieve(params[:customer_id])
        subscription = customer.subscriptions.retrieve(params[:subscription_id])
        subscription.delete

        # Also cancel licence in evercam database
        licence = Licence.where(subscription_id: params[:subscription_id]).first
        licence.update_attribute(:cancel_licence, true)
        respond_to do |format|
          format.html { redirect_to licence_report_path, notice: "Licence canceled successfully." }
          format.json { render json: subscription }
        end
      end
    rescue => error
      notify_airbrake(error)
      respond_to do |format|
        format.html { redirect_to licence_report_path }
        format.json { render json: error.message, status: :unprocessable_entity }
      end
    end
  end

  def update
    begin
      licence = Licence.where(id: params[:licence_id], user_id: params[:user_id]).first
      licence.update_attributes(
        description: params["licence_desc"],
        total_cameras: params["total_cameras"],
        storage: params["storage"],
        amount: params["amount"].to_i * 100,
        start_date: DateTime.parse(params["start_date"]),
        end_date: DateTime.parse(params["end_date"]),
        paid: params["paid"]
      )
      message = "Licence updated successfully"
      saved = true
    rescue => error
      notify_airbrake(error)
      message = error.message
    end
    respond_to do |format|
      if saved
        format.html { redirect_to licence_report_path, notice: message }
        format.json { render json: licence }
      else
        format.html { redirect_to licence_report_path }
        format.json { render json: message, status: :unprocessable_entity }
      end
    end
  end

  def auto_renewal
    begin
      if params[:customer_id] && params[:subscription_id]
        customer = Stripe::Customer.retrieve(params[:customer_id])
        subscription = customer.subscriptions.retrieve(params[:subscription_id])
        subscription.cancel_at_period_end = params[:auto_renew]
        subscription.save
        respond_to do |format|
          format.html { redirect_to licence_report_path, notice: "Licence auto renewal #{params[:auto_renew] ? "disabled" : "enabled"} successfully" }
          format.json { render json: subscription }
        end
      end
    rescue => error
      notify_airbrake(error)
      respond_to do |format|
        format.html { redirect_to licence_report_path }
        format.json { render json: error.message, status: :unprocessable_entity }
      end
    end
  end

  private

  def add_stripe_licence
    @customers.each do |customer|
      licences = customer.subscriptions.data
      licences.each do |licence|
        unless Licence.where(cancel_licence: false, subscription_id: licence.id).count > 0
          user = EvercamUser.where(stripe_customer_id: customer.id).includes(:country).first
          storage = ""
          case licence.plan["id"]
          when "24-hours-recording", "24-hours-recording-annual"
            storage = 1
          when "7-days-recording", "7-days-recording-annual"
            storage = 7
          when "30-days-recording", "30-days-recording-annual"
            storage = 30
          when "90-days-recording", "90-days-recording-annual"
            storage = 90
          when "infinity", "infinity-annual"
            storage = -1
          end
          licence = Licence.new(
            user_id: user.id,
            subscription_id: licence.id,
            description: licence.plan.name,
            total_cameras: licence.quantity,
            storage: storage,
            amount: licence.plan.amount,
            start_date: Time.at(licence.current_period_start),
            end_date: Time.at(licence.current_period_end),
            created_at: Time.at(licence.start),
            auto_renew: !licence.cancel_at_period_end,
            paid: true
          )
          licence.save
        end
      end
    end
  end
end
