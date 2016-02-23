class LicenceReportsController < ApplicationController
  before_action :authorize_admin
  require "stripe"

  def index
    begin
      @customers = Stripe::Customer.all(limit: 200)
      @custom_licences = Licence.where(cancel_licence: false).all
      @users = EvercamUser.all
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
        created_at: Time.now
      )
      respond_to do |format|
        if @licence.save
          format.html { redirect_to licence_report_path, notice: 'Licence successfully created' }
          format.json { render json: @licence }
        else
          format.html { redirect_to licence_report_path }
          format.json { render json: @licence.errors.full_messages, status: :unprocessable_entity }
        end
      end
    rescue => error
      notify_airbrake(error)
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
end
