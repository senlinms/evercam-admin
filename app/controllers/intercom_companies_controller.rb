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
      add_users(com)
      result = {success: true, company: com}
    rescue => error
      result = {success: false, message: "#{error.message}"}
    end
    render json: result
  end

  def add_users(company)
    users = User.connection.select_all("select * from users where email like '%@#{company.company_id}'")

    Spawnling.new do
      intercom = connect_intercom
      puts "Start company #{company.company_id}"

      users.each do |user|
        begin
          ic_user = intercom.users.find(:user_id => user["username"])
        rescue Intercom::ResourceNotFound
          # Ignore it
        end
        unless ic_user.nil?
          ic_user.companies = [{company_id: "#{company.company_id}"}]
          intercom.users.save(ic_user)
          puts "Update user (#{user["id"]}): #{user["username"]}\t#{user["email"]}"
        end
      end
      puts "Process completed"
    end
  end
end
