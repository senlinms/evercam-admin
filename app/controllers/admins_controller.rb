class AdminsController < ApplicationController
  def index
    @admins = User.all
  end
end
