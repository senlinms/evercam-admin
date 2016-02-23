class SnapshotExtractor < ActiveRecord::Base
	establish_connection "evercam_db_#{Rails.env}".to_sym

	belongs_to :camera
	require "rmega"
	require "aws-sdk-v1"
	require 'open-uri'

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
				# created_ats = [{"created_at"=>"2016-01-09 03:58:27+00"}, {"created_at"=>"2016-01-09 09:23:40+00"}, {"created_at"=>"2016-01-10 00:02:00+00"}, {"created_at"=>"2016-01-10 01:18:47+00"}, {"created_at"=>"2016-01-10 03:57:48+00"}, {"created_at"=>"2016-01-10 14:38:07+00"}, {"created_at"=>"2016-01-12 08:37:42+00"}, {"created_at"=>"2016-01-13 10:32:41+00"}, {"created_at"=>"2016-01-13 10:34:54+00"}, {"created_at"=>"2016-01-13 10:51:44+00"}, {"created_at"=>"2016-01-13 10:52:16+00"}, {"created_at"=>"2016-01-13 11:10:06+00"}, {"created_at"=>"2016-01-13 11:48:45+00"}, {"created_at"=>"2016-01-13 12:11:47+00"}, {"created_at"=>"2016-01-13 12:27:48+00"}, {"created_at"=>"2016-01-13 13:37:05+00"}, {"created_at"=>"2016-01-13 13:51:24+00"}, {"created_at"=>"2016-01-13 14:04:13+00"}, {"created_at"=>"2016-01-14 01:03:56+00"}, {"created_at"=>"2016-01-14 01:46:00+00"}, {"created_at"=>"2016-01-14 03:48:56+00"}, {"created_at"=>"2016-01-14 05:35:59+00"}, {"created_at"=>"2016-01-14 07:00:52+00"}, {"created_at"=>"2016-01-14 12:30:58+00"}, {"created_at"=>"2016-01-14 15:45:21+00"}, {"created_at"=>"2016-01-14 17:07:26+00"}, {"created_at"=>"2016-01-14 20:37:38+00"}, {"created_at"=>"2016-01-14 20:49:07+00"}, {"created_at"=>"2016-01-14 21:02:43+00"}, {"created_at"=>"2016-01-14 21:55:34+00"}, {"created_at"=>"2016-01-15 00:19:20+00"}, {"created_at"=>"2016-01-15 00:32:14+00"}, {"created_at"=>"2016-01-15 01:00:24+00"}, {"created_at"=>"2016-01-15 01:20:11+00"}, {"created_at"=>"2016-01-15 02:57:00+00"}, {"created_at"=>"2016-01-15 04:24:10+00"}, {"created_at"=>"2016-01-15 05:51:28+00"}, {"created_at"=>"2016-01-15 07:47:26+00"}, {"created_at"=>"2016-01-15 09:46:08+00"}, {"created_at"=>"2016-01-15 10:04:56+00"}, {"created_at"=>"2016-01-15 10:34:08+00"}, {"created_at"=>"2016-01-15 12:52:50+00"}, {"created_at"=>"2016-01-15 15:09:01+00"}, {"created_at"=>"2016-01-15 15:18:11+00"}, {"created_at"=>"2016-01-15 22:44:06+00"}, {"created_at"=>"2016-01-15 22:47:23+00"}, {"created_at"=>"2016-01-15 22:50:39+00"}, {"created_at"=>"2016-01-15 23:07:46+00"}, {"created_at"=>"2016-01-15 23:31:15+00"}, {"created_at"=>"2016-01-15 23:55:28+00"}, {"created_at"=>"2016-01-15 23:58:57+00"}, {"created_at"=>"2016-01-16 01:06:41+00"}, {"created_at"=>"2016-01-16 01:25:03+00"}, {"created_at"=>"2016-01-16 01:46:32+00"}, {"created_at"=>"2016-01-16 02:16:10+00"}, {"created_at"=>"2016-01-16 03:02:29+00"}, {"created_at"=>"2016-01-16 03:35:28+00"}, {"created_at"=>"2016-01-16 03:46:08+00"}, {"created_at"=>"2016-01-16 06:05:09+00"}, {"created_at"=>"2016-01-16 07:10:25+00"}, {"created_at"=>"2016-01-16 11:22:58+00"}, {"created_at"=>"2016-01-16 12:20:17+00"}, {"created_at"=>"2016-01-16 12:45:32+00"}, {"created_at"=>"2016-01-16 13:03:07+00"}, {"created_at"=>"2016-01-16 13:14:30+00"}, {"created_at"=>"2016-01-16 13:39:33+00"}, {"created_at"=>"2016-01-16 14:36:11+00"}, {"created_at"=>"2016-01-16 15:06:35+00"}, {"created_at"=>"2016-01-16 17:23:31+00"}, {"created_at"=>"2016-01-16 17:32:04+00"}, {"created_at"=>"2016-01-16 19:07:11+00"}, {"created_at"=>"2016-01-16 19:41:27+00"}, {"created_at"=>"2016-01-16 20:16:25+00"}, {"created_at"=>"2016-01-16 21:04:09+00"}, {"created_at"=>"2016-01-16 22:38:35+00"}, {"created_at"=>"2016-01-16 22:44:50+00"}, {"created_at"=>"2016-01-16 22:51:59+00"}, {"created_at"=>"2016-01-16 23:23:45+00"}, {"created_at"=>"2016-01-17 00:52:19+00"}, {"created_at"=>"2016-01-17 00:55:58+00"}, {"created_at"=>"2016-01-17 01:04:12+00"}, {"created_at"=>"2016-01-17 02:03:41+00"}, {"created_at"=>"2016-01-17 02:57:45+00"}, {"created_at"=>"2016-01-17 03:53:08+00"}, {"created_at"=>"2016-01-17 03:58:14+00"}, {"created_at"=>"2016-01-17 04:22:19+00"}, {"created_at"=>"2016-01-17 04:25:46+00"}, {"created_at"=>"2016-01-17 05:01:27+00"}, {"created_at"=>"2016-01-17 06:08:02+00"}, {"created_at"=>"2016-01-17 06:44:59+00"}, {"created_at"=>"2016-01-17 08:34:35+00"}, {"created_at"=>"2016-01-17 08:40:49+00"}, {"created_at"=>"2016-01-17 09:01:20+00"}, {"created_at"=>"2016-01-17 09:10:32+00"}, {"created_at"=>"2016-01-17 10:47:06+00"}, {"created_at"=>"2016-01-17 10:56:38+00"}, {"created_at"=>"2016-01-17 11:13:45+00"}, {"created_at"=>"2016-01-17 12:07:01+00"}, {"created_at"=>"2016-01-17 12:25:03+00"}, {"created_at"=>"2016-01-17 13:13:20+00"}, {"created_at"=>"2016-01-17 14:14:08+00"}, {"created_at"=>"2016-01-17 15:17:13+00"}, {"created_at"=>"2016-01-17 15:38:52+00"}, {"created_at"=>"2016-01-17 15:42:55+00"}, {"created_at"=>"2016-01-17 16:02:16+00"}, {"created_at"=>"2016-01-17 16:29:25+00"}, {"created_at"=>"2016-01-17 17:06:18+00"}, {"created_at"=>"2016-01-17 18:09:22+00"}, {"created_at"=>"2016-01-17 18:29:43+00"}, {"created_at"=>"2016-01-17 20:21:30+00"}, {"created_at"=>"2016-01-17 20:33:51+00"}, {"created_at"=>"2016-01-17 20:44:18+00"}, {"created_at"=>"2016-01-17 21:12:54+00"}, {"created_at"=>"2016-01-17 21:17:01+00"}, {"created_at"=>"2016-01-17 21:40:55+00"}, {"created_at"=>"2016-01-17 23:19:46+00"}, {"created_at"=>"2016-01-17 23:23:24+00"}, {"created_at"=>"2016-01-17 23:43:29+00"}, {"created_at"=>"2016-01-18 01:10:15+00"}, {"created_at"=>"2016-01-18 01:22:29+00"}, {"created_at"=>"2016-01-18 01:33:38+00"}, {"created_at"=>"2016-01-18 01:38:26+00"}, {"created_at"=>"2016-01-18 03:54:20+00"}, {"created_at"=>"2016-01-18 04:08:41+00"}, {"created_at"=>"2016-01-18 05:12:07+00"}, {"created_at"=>"2016-01-18 07:46:24+00"}, {"created_at"=>"2016-01-18 08:06:18+00"}, {"created_at"=>"2016-01-18 08:20:16+00"}, {"created_at"=>"2016-01-18 09:56:44+00"}, {"created_at"=>"2016-01-18 10:28:12+00"}, {"created_at"=>"2016-01-18 10:32:55+00"}, {"created_at"=>"2016-01-18 10:55:34+00"}, {"created_at"=>"2016-01-18 11:13:30+00"}, {"created_at"=>"2016-01-18 11:17:21+00"}, {"created_at"=>"2016-01-18 11:23:15+00"}, {"created_at"=>"2016-01-18 11:30:13+00"}, {"created_at"=>"2016-01-18 12:35:38+00"}, {"created_at"=>"2016-01-18 12:55:12+00"}, {"created_at"=>"2016-01-18 14:37:48+00"}, {"created_at"=>"2016-01-18 16:49:36+00"}, {"created_at"=>"2016-01-18 17:08:19+00"}, {"created_at"=>"2016-01-18 17:38:44+00"}, {"created_at"=>"2016-01-18 17:44:18+00"}, {"created_at"=>"2016-01-18 17:56:04+00"}, {"created_at"=>"2016-01-18 18:37:41+00"}, {"created_at"=>"2016-01-18 19:34:56+00"}, {"created_at"=>"2016-01-18 20:11:57+00"}, {"created_at"=>"2016-01-18 20:23:47+00"}, {"created_at"=>"2016-01-18 20:41:31+00"}, {"created_at"=>"2016-01-18 23:22:21+00"}, {"created_at"=>"2016-01-18 23:59:48+00"}, {"created_at"=>"2016-01-19 00:16:23+00"}, {"created_at"=>"2016-01-19 00:36:19+00"}, {"created_at"=>"2016-01-19 02:30:54+00"}, {"created_at"=>"2016-01-19 03:09:43+00"}, {"created_at"=>"2016-01-19 03:27:20+00"}, {"created_at"=>"2016-01-19 04:18:40+00"}, {"created_at"=>"2016-01-19 05:55:48+00"}, {"created_at"=>"2016-01-19 07:27:58+00"}, {"created_at"=>"2016-01-19 09:44:13+00"}, {"created_at"=>"2016-01-19 10:11:45+00"}, {"created_at"=>"2016-01-19 10:25:41+00"}, {"created_at"=>"2016-01-19 10:52:45+00"}, {"created_at"=>"2016-01-19 12:13:15+00"}, {"created_at"=>"2016-01-19 12:49:44+00"}, {"created_at"=>"2016-01-19 14:12:53+00"}, {"created_at"=>"2016-01-19 14:52:12+00"}, {"created_at"=>"2016-01-19 14:57:00+00"}, {"created_at"=>"2016-01-19 15:20:23+00"}, {"created_at"=>"2016-01-19 15:34:06+00"}, {"created_at"=>"2016-01-19 18:32:52+00"}, {"created_at"=>"2016-01-19 18:44:37+00"}, {"created_at"=>"2016-01-19 20:29:45+00"}, {"created_at"=>"2016-01-19 21:08:57+00"}, {"created_at"=>"2016-01-19 22:07:52+00"}, {"created_at"=>"2016-01-19 23:06:41+00"}, {"created_at"=>"2016-01-19 23:20:10+00"}, {"created_at"=>"2016-01-20 00:18:34+00"}, {"created_at"=>"2016-01-20 00:42:52+00"}, {"created_at"=>"2016-01-20 01:44:30+00"}, {"created_at"=>"2016-01-20 02:47:15+00"}, {"created_at"=>"2016-01-20 04:37:40+00"}, {"created_at"=>"2016-01-20 06:17:40+00"}, {"created_at"=>"2016-01-20 06:55:29+00"}, {"created_at"=>"2016-01-20 07:53:51+00"}, {"created_at"=>"2016-01-20 10:00:24+00"}, {"created_at"=>"2016-01-20 10:17:10+00"}, {"created_at"=>"2016-01-20 10:52:27+00"}, {"created_at"=>"2016-01-20 11:11:25+00"}, {"created_at"=>"2016-01-20 12:12:21+00"}, {"created_at"=>"2016-01-20 14:54:37+00"}, {"created_at"=>"2016-01-20 15:20:00+00"}, {"created_at"=>"2016-01-20 16:46:56+00"}, {"created_at"=>"2016-01-20 17:39:50+00"}, {"created_at"=>"2016-01-20 17:57:17+00"}, {"created_at"=>"2016-01-20 18:22:31+00"}, {"created_at"=>"2016-01-20 21:20:06+00"}, {"created_at"=>"2016-01-20 21:57:01+00"}, {"created_at"=>"2016-01-20 23:30:10+00"}, {"created_at"=>"2016-01-20 23:36:16+00"}, {"created_at"=>"2016-01-20 23:46:30+00"}, {"created_at"=>"2016-01-21 00:14:40+00"}, {"created_at"=>"2016-01-21 00:37:25+00"}, {"created_at"=>"2016-01-21 00:42:59+00"}, {"created_at"=>"2016-01-21 02:56:41+00"}, {"created_at"=>"2016-01-21 03:10:21+00"}, {"created_at"=>"2016-01-21 03:48:22+00"}, {"created_at"=>"2016-01-21 04:10:54+00"}, {"created_at"=>"2016-01-21 06:55:46+00"}, {"created_at"=>"2016-01-21 10:00:45+00"}, {"created_at"=>"2016-01-21 11:32:18+00"}, {"created_at"=>"2016-01-21 15:41:51+00"}, {"created_at"=>"2016-01-21 15:56:09+00"}, {"created_at"=>"2016-01-21 17:43:55+00"}, {"created_at"=>"2016-01-21 19:09:17+00"}, {"created_at"=>"2016-01-21 19:50:54+00"}, {"created_at"=>"2016-01-21 21:46:09+00"}, {"created_at"=>"2016-01-21 22:02:14+00"}, {"created_at"=>"2016-01-21 23:25:50+00"}, {"created_at"=>"2016-01-21 23:58:42+00"}, {"created_at"=>"2016-01-22 02:18:57+00"}, {"created_at"=>"2016-01-22 02:57:23+00"}, {"created_at"=>"2016-01-22 04:06:13+00"}, {"created_at"=>"2016-01-22 04:26:36+00"}, {"created_at"=>"2016-01-22 05:05:31+00"}, {"created_at"=>"2016-01-22 06:07:31+00"}, {"created_at"=>"2016-01-22 06:13:01+00"}, {"created_at"=>"2016-01-22 06:24:32+00"}, {"created_at"=>"2016-01-22 06:39:59+00"}, {"created_at"=>"2016-01-22 10:32:46+00"}, {"created_at"=>"2016-01-22 10:37:15+00"}, {"created_at"=>"2016-01-22 11:08:03+00"}, {"created_at"=>"2016-01-22 11:33:56+00"}, {"created_at"=>"2016-01-22 11:39:52+00"}, {"created_at"=>"2016-01-22 11:54:13+00"}, {"created_at"=>"2016-01-22 12:14:49+00"}, {"created_at"=>"2016-01-22 15:09:51+00"}, {"created_at"=>"2016-01-22 16:14:55+00"}, {"created_at"=>"2016-01-22 16:33:22+00"}, {"created_at"=>"2016-01-22 16:45:26+00"}, {"created_at"=>"2016-01-22 17:14:39+00"}, {"created_at"=>"2016-01-22 17:26:43+00"}, {"created_at"=>"2016-01-22 17:46:25+00"}, {"created_at"=>"2016-01-22 17:54:03+00"}, {"created_at"=>"2016-01-22 18:09:46+00"}, {"created_at"=>"2016-01-22 19:10:24+00"}, {"created_at"=>"2016-01-22 19:14:50+00"}, {"created_at"=>"2016-01-22 19:20:02+00"}, {"created_at"=>"2016-01-22 20:15:49+00"}, {"created_at"=>"2016-01-22 21:49:18+00"}, {"created_at"=>"2016-01-22 22:00:58+00"}, {"created_at"=>"2016-01-22 22:06:49+00"}, {"created_at"=>"2016-01-22 22:54:02+00"}, {"created_at"=>"2016-01-22 22:54:31+00"}, {"created_at"=>"2016-01-22 22:59:50+00"}, {"created_at"=>"2016-01-22 23:14:15+00"}, {"created_at"=>"2016-01-22 23:36:38+00"}, {"created_at"=>"2016-01-23 00:05:59+00"}, {"created_at"=>"2016-01-23 02:13:06+00"}, {"created_at"=>"2016-01-23 02:50:56+00"}, {"created_at"=>"2016-01-23 04:01:25+00"}, {"created_at"=>"2016-01-23 04:23:17+00"}, {"created_at"=>"2016-01-23 04:40:34+00"}, {"created_at"=>"2016-01-23 05:42:48+00"}, {"created_at"=>"2016-01-23 06:09:22+00"}, {"created_at"=>"2016-01-23 06:31:50+00"}, {"created_at"=>"2016-01-23 06:41:32+00"}, {"created_at"=>"2016-01-23 06:48:49+00"}, {"created_at"=>"2016-01-23 08:03:33+00"}, {"created_at"=>"2016-01-23 08:24:51+00"}, {"created_at"=>"2016-01-23 09:02:10+00"}, {"created_at"=>"2016-01-23 09:31:46+00"}, {"created_at"=>"2016-01-23 10:14:38+00"}, {"created_at"=>"2016-01-23 10:21:39+00"}, {"created_at"=>"2016-01-23 12:17:09+00"}, {"created_at"=>"2016-01-23 15:08:07+00"}, {"created_at"=>"2016-01-23 15:32:51+00"}, {"created_at"=>"2016-01-23 16:03:35+00"}, {"created_at"=>"2016-01-23 16:10:45+00"}, {"created_at"=>"2016-01-23 16:17:56+00"}, {"created_at"=>"2016-01-23 18:55:41+00"}, {"created_at"=>"2016-01-23 19:17:50+00"}, {"created_at"=>"2016-01-23 19:26:22+00"}, {"created_at"=>"2016-01-23 20:01:04+00"}, {"created_at"=>"2016-01-23 20:06:50+00"}, {"created_at"=>"2016-01-23 22:07:41+00"}, {"created_at"=>"2016-01-23 22:31:41+00"}, {"created_at"=>"2016-01-23 22:46:09+00"}, {"created_at"=>"2016-01-24 00:08:07+00"}, {"created_at"=>"2016-01-24 00:37:26+00"}, {"created_at"=>"2016-01-24 00:49:58+00"}, {"created_at"=>"2016-01-24 01:10:53+00"}, {"created_at"=>"2016-01-24 01:29:42+00"}, {"created_at"=>"2016-01-24 02:21:02+00"}, {"created_at"=>"2016-01-24 08:58:10+00"}, {"created_at"=>"2016-01-24 09:04:41+00"}, {"created_at"=>"2016-01-24 09:17:25+00"}, {"created_at"=>"2016-01-24 12:21:43+00"}, {"created_at"=>"2016-01-24 12:52:38+00"}, {"created_at"=>"2016-01-24 13:19:48+00"}, {"created_at"=>"2016-01-24 14:36:57+00"}, {"created_at"=>"2016-01-24 15:40:23+00"}, {"created_at"=>"2016-01-24 15:53:36+00"}, {"created_at"=>"2016-01-24 16:21:15+00"}, {"created_at"=>"2016-01-24 16:32:07+00"}, {"created_at"=>"2016-01-24 17:03:47+00"}, {"created_at"=>"2016-01-24 17:29:27+00"}, {"created_at"=>"2016-01-24 18:02:07+00"}, {"created_at"=>"2016-01-24 18:13:40+00"}, {"created_at"=>"2016-01-24 18:20:56+00"}, {"created_at"=>"2016-01-24 19:26:41+00"}, {"created_at"=>"2016-01-24 21:31:41+00"}, {"created_at"=>"2016-01-24 21:41:27+00"}, {"created_at"=>"2016-01-24 21:49:36+00"}, {"created_at"=>"2016-01-24 23:35:21+00"}, {"created_at"=>"2016-01-24 23:47:17+00"}, {"created_at"=>"2016-01-25 00:15:20+00"}, {"created_at"=>"2016-01-25 00:46:44+00"}, {"created_at"=>"2016-01-25 01:50:16+00"}, {"created_at"=>"2016-01-25 02:14:45+00"}, {"created_at"=>"2016-01-25 02:29:24+00"}, {"created_at"=>"2016-01-25 03:05:48+00"}, {"created_at"=>"2016-01-25 03:30:56+00"}, {"created_at"=>"2016-01-25 05:28:26+00"}, {"created_at"=>"2016-01-25 07:57:35+00"}, {"created_at"=>"2016-01-25 09:21:19+00"}, {"created_at"=>"2016-01-25 11:38:24+00"}, {"created_at"=>"2016-01-25 13:43:42+00"}, {"created_at"=>"2016-01-25 14:30:14+00"}, {"created_at"=>"2016-01-25 15:57:01+00"}, {"created_at"=>"2016-01-25 16:02:26+00"}, {"created_at"=>"2016-01-25 16:33:48+00"}, {"created_at"=>"2016-01-25 16:46:16+00"}, {"created_at"=>"2016-01-25 18:17:43+00"}, {"created_at"=>"2016-01-25 20:40:19+00"}, {"created_at"=>"2016-01-25 21:18:54+00"}, {"created_at"=>"2016-01-25 22:28:00+00"}, {"created_at"=>"2016-01-25 23:16:45+00"}, {"created_at"=>"2016-01-26 00:00:50+00"}, {"created_at"=>"2016-01-26 01:43:37+00"}, {"created_at"=>"2016-01-26 01:58:51+00"}, {"created_at"=>"2016-01-26 02:05:12+00"}, {"created_at"=>"2016-01-26 02:52:36+00"}, {"created_at"=>"2016-01-26 04:31:44+00"}, {"created_at"=>"2016-01-26 05:41:31+00"}, {"created_at"=>"2016-01-26 05:58:48+00"}]
				created_at_spdays = refine_days(created_ats, set_days)
				created_at_sptime = refine_times(created_at_spdays, set_timings, set_days)
				created_at = refine_intervals(created_at_sptime, interval)
			rescue => error
				notify_airbrake(error)
			end

			begin
				storage = connect_mega
				snapshot_bucket = connect_bucket
				new_folder = storage.root.create_folder("#{exid}")
				folder = storage.nodes.find do |node|
				  node.type == :folder and node.name == "#{exid}"
				end
				to = folder.create_folder("#{mega_id}")
				created_at.each do |snap|
					snap_i = DateTime.parse(snap).to_i
					s3_object = snapshot_bucket.objects["#{exid}/snapshots/#{snap_i}.jpg"]
					if s3_object.exists?
						snap_url = s3_object.url_for(:get, {expires: 1.years.from_now, secure: true}).to_s
						File.open("url.txt", 'w') { |file| file.write(snap_url) }
						open('image.jpg', 'wb') do |file|
						  file << open(snap_url).read
						end
						to.upload('image.jpg')
					end
				end
				@snapshot_request.update_attribute(:status, 3)
			rescue => error
				error
			end		
		end
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

	def self.refine_times(created_ats, timings, days)
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

	def self.refine_intervals(created_ats, interval)
		created_at = [created_ats.first]
		last_created_at = DateTime.parse(created_ats.last)
		index = 1
		index_for_dt = 0
		length = created_ats.length
		(1..length).each do |single|
			if (DateTime.parse(created_at[index_for_dt]) + interval.minutes) <= last_created_at
				temp = DateTime.parse(created_at[index_for_dt]) + interval.minutes
				created_at[index] = temp.to_s
				index_for_dt += 1
				index += 1
			end
		end
		created_at
	end
end
