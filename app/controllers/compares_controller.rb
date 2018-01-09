class ComparesController < ApplicationController
  protect_from_forgery with: :null_session

  def index
    @compares = Compare.all
  end

  def delete
    @compare =  Compare.find(params["id"])
    begin
      @compare.delete
      render json: {deleted: true}
    rescue
      render json: {deleted: false}
    end
  end
end