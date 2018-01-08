class ComparesController < ApplicationController
  def index
    @compares = Compare.all
  end
end