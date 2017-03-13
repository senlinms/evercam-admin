class IntercomCompaniesController < ApplicationController
  before_action :authorize_admin

  def index
    intercom = connect_intercom
    @companies = intercom.companies.all
  end

  def create
    result = {success: true}
    begin
      intercom = connect_intercom
      com = intercom.companies.create(:company_id => "#{params["company_id"]}", :name => "#{params["company_name"]}", :created_at => Time.now.to_i)
      result = {success: true, company: com}
    rescue => error
      result = {success: false, message: "#{error.message}"}
    end
    render json: result
  end
end