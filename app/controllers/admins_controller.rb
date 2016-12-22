class AdminsController < ApplicationController
  def index
    @admins = User.all
  end

  def create
    begin
      @admin = User.create!({
        username: params[:username],
        firstname: params[:firstname],
        lastname: params[:lastname],
        email: params[:email],
        is_admin: true,
        password: params[:password],
        password_confirmation: params[:password]
      })

      render json: @admin.to_json
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
