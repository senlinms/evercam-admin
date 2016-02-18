class LicenceReportsController < ApplicationController
  before_action :authorize_admin
  require "stripe"

  def index
    @customers = Stripe::Customer.all(limit: 200)
  end
end