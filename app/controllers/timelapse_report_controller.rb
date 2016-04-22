class TimelapseReportController < ApplicationController
  require "open-uri"

  def index
    content = open("#{ENV['TIMELAPSE_URL']}/#{ENV['TIMELAPSE_ID']}/#{ENV['TIMELAPSE_KEY']}").read
    @timelapses = JSON.parse(content)
  end
end
