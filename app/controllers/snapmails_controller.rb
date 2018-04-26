class SnapmailsController < ApplicationController
  require "nokogiri"

  def index
    @snapmails = Snapmail.all
  end

  def history   
  end

  def get_email_temaplate
    snapmail = SnapmailLogs.find(params[:id])
    render json: {
      body: set_jpeg_src(snapmail.body, snapmail.image_timestamp),
    }
  end

  def get_history_data
    @reports = SnapmailLogs.where("DATE(inserted_at) >= ? and DATE(inserted_at) <= ?", params[:fromDate], params[:toDate]).order('inserted_at desc')
    records = []
    @reports.each do |report|
      records[records.length] = [
        DateTime.strptime(report.image_timestamp, "%s").strftime("%A, %d %b %Y %l:%M %p"),
        report.recipients,
        body(report.body),
        "",
        report.subject,
        report.id
      ]
    end
    if !records.blank?
      render json: records
    end
  end

  def body(html)
    doc = Nokogiri::HTML(html)
    image_nodes = doc.css(".last-snapmail-snapshot")
    image_nodes.each do |image|
      image['src'] = ""
    end
    doc.to_html
  end

  def set_jpeg_src(body, timestamp)
    doc = Nokogiri::HTML(body)
    image_nodes = doc.css(".last-snapmail-snapshot")
    camera_id = image_nodes.first['id']
    image_nodes.first['src'] = get_s3_pre_auth_url(timestamp, camera_id)
    doc.to_html
  end

  def get_s3_pre_auth_url(timestamp, camera_id)
    bucket = get_s3_bucket()
    jpeg_path = DateTime.strptime(timestamp, "%s").strftime("%Y/%m/%d/%H/%M_%S_000")
    bucket.objects["#{camera_id}/snapmails/#{jpeg_path}.jpg"].url_for(:get, {expires: 1.years.from_now, secure: true}).to_s
  end

  def get_s3_bucket
    access_key_id = "#{ENV['AWS_ACCESS_KEY']}"
    secret_access_key = "#{ENV['AWS_SECRET_KEY']}"
    s3 = AWS::S3.new(
      access_key_id: access_key_id,
      secret_access_key: secret_access_key,
    )
    s3.buckets["evercam-camera-assets"]
  end
end