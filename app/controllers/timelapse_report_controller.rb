class TimelapseReportController < ApplicationController
  require "open-uri"

  def index
    content = open(ENV['TIMELAPSE_URL']).read
    @timelapses = JSON.parse(content)
  end
end
