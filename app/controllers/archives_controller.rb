class ArchivesController < ApplicationController

  def index
    @archives = Archive.all
  end
end
