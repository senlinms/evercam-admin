class AdminsController < ApplicationController
  def index
    @admins = User.where('is_admin = ?', true).all
  end

  def create
    begin
      @admin = User.create!({
        username: params[:username],
        firstname: params[:firstname],
        lastname: params[:lastname],
        email: params[:email],
        is_admin: params[:is_admin],
        password: params[:password],
        password_confirmation: params[:password]
      })

      render json: @admin.to_json
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def make_admin
    begin
      admin = User.find_by(email: params[:email])
      if admin.nil?
        render json: "Email '#{params[:email]}' does not exist.", status: :unprocessable_entity  
      else
        admin.is_admin = true
        admin.save
        render json: admin.to_json
      end
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def auto_complete
    begin
      admin = User.find_by(email: params[:email])
      render json: admin.to_json
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def update
    @admin = User.find(params[:id])

    @admin.firstname = params[:firstname] if params[:firstname]
    @admin.lastname = params[:lastname] if params[:lastname]
    @admin.username = params[:username] if params[:username]
    @admin.email = params[:email] if params[:email]
    @admin.is_admin = params[:is_admin] if params[:is_admin]
    if params[:password]
      @admin.password = params[:password]
      @admin.password_confirmation = params[:password]
    end

    begin
      if @admin.save
        render json: @admin.to_json
      else
        render json: @admin.errors.full_messages, status: :unprocessable_entity
      end
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @admin = User.where(id: params[:admin_id]).delete_all
      render json: @admin.to_json
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end
end
