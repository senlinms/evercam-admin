class SnapshotReportsController < ApplicationController
	
  def index
		@cameras = Camera.all.includes(:user)
	end
end
