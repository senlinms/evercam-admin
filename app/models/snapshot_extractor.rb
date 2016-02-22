class SnapshotExtractor < ActiveRecord::Base
	establish_connection "evercam_db_#{Rails.env}".to_sym

	belongs_to :camera
	require "rmega"
	require "aws-sdk-v1"

  def self.connect_mega
    storage = Rmega.login("#{ENV['MEGA_EMAIL']}", "#{ENV['MEGA_PASSWORD']}")
    storage
  end

  def self.connect_bucket
    access_key_id = "#{ENV['AWS_ACCESS_KEY']}"
    secret_access_key = "#{ENV['AWS_SECRET_KEY']}"
    s3 = AWS::S3.new(
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
    )
    bucket = s3.buckets["evercam-camera-assets"]
    bucket
  end

	def self.extract_snapshots
		running = SnapshotExtractor.where(status: 1).any?
		unless running
			@snapshot_request = SnapshotExtractor.where(status: 0).first
			@snapshot_request.update_attribute(:status, 1)
			camera_id = @snapshot_request.camera_id
			exid = Camera.find(camera_id).exid
			mega_id = @snapshot_request.id
			from_date = @snapshot_request.from_date.strftime("%Y%m%d")
			to_date = @snapshot_request.to_date.strftime("%Y%m%d")
			interval = @snapshot_request.interval
			@days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
			set_days = []
			set_timings = []

			index = 0
			@days.each do |day|
				if @snapshot_request.schedule[day].present?
					set_days[index] = day
					set_timings[index] = @snapshot_request.schedule[day]
					index += 1
				end
			end

			begin
				created_ats = Snapshot.connection.select_all("SELECT created_at from snapshots WHERE snapshot_id >= '#{camera_id}_#{from_date}' AND snapshot_id <= '#{camera_id}_#{to_date}'")
				created_at_spdays = refine_days(created_ats,set_days)
				created_at_sptime = refine_times(created_at_spdays,set_timings,set_days)
				created_at = refine_intervals(created_at_sptime,interval)
				@snapshot_request.update_attribute(:status, 9)
			rescue => error
				notify_airbrake(error)
			end

			begin
				storage = connect_mega
				new_folder = storage.root.create_folder("#{exid}")
				folder = storage.nodes.find do |node|
				  node.type == :folder and node.name == "#{exid}"
				end
				folder.create_folder("#{mega_id}")
				# images = []
				snapshot_bucket = connect_bucket
				created_at.each do |snap|
					s3_object = snapshot_bucket.objects["#{exid}/snapshots/#{snap.to_i}.jpg"]
					if s3_object.exists?
						image = s3_object.read
						data = Base64.encode64(image).gsub("\n", '')
						folder.upload(data)
					end
				end
				@snapshot_request.update_attribute(:status, 3)
			rescue => error
				notify_airbrake(error)
			end		
		end
		# created_at
	end

	private

	def self.refine_days(created_ats, days)
		created_at = []
		index = 0
		created_ats.each do |single|
			days.each do |day|
				if day == Date.parse(single["created_at"]).strftime("%A")
					created_at[index] = single["created_at"]
					index += 1
				end
			end
		end
		created_at
	end

	def self.refine_times(created_ats,timings,days)
		created_at = []
		index = 0
		day_index = 0
		days_times =  days.zip(timings.flatten)
		one = 1
		zero = 0
		created_ats.each do |single|
			days_times.each do |day_time|
				if Date.parse(single).strftime("%A") == day_time[day_index]
					start_time = DateTime.parse(day_time[one].split("-")[zero]).strftime("%H:%M")
					end_time = DateTime.parse(day_time[one].split("-")[one]).strftime("%H:%M")
					created_at_time = DateTime.parse(single).strftime("%H:%M")
					if created_at_time >= start_time && created_at_time <= end_time
						created_at[index] = single
						index += 1
					end
				end
			end
		end
		created_at
	end

	def self.refine_intervals(created_ats,interval)
		created_at = [DateTime.parse(created_ats.first)]
		last_created_at = DateTime.parse(created_ats.last)
		index = 1
		index_for_dt = 0
		length = created_ats.length
		(1..length).each do |single|
			if (created_at[index_for_dt] + interval.minutes) <= last_created_at
				created_at[index] = created_at[index_for_dt] + interval.minutes
				index_for_dt += 1
				index += 1
			end
		end
		created_at
	end
end
