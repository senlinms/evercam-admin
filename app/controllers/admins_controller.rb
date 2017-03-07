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
        is_admin: params[:is_admin],
        password: params[:password],
        password_confirmation: params[:password]
      })

      render json: @admin.to_json
    rescue => error
      render json: error.message, status: :unprocessable_entity
    end
  end

  def update
    @admin = User.find(params[:id])

    @admin.firstname = params[:firstname]
    @admin.lastname = params[:lastname]
    @admin.username = params[:username]
    @admin.email = params[:email]
    @admin.is_admin = params[:is_admin]
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
