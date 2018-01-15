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
      body: snapmail.body,
      timestamp: snapmail.image_timestamp,
      filer_url: filer_url
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
end