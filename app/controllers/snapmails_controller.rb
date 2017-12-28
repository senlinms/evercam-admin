class SnapmailsController < ApplicationController

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
    if params[:date]
      date = params[:date]
    end
    @reports = SnapmailLogs.where("DATE(inserted_at) = ?", date).order('inserted_at desc')
    records = []
    @reports.each do |report|
      records[records.length] = [
        DateTime.strptime(report.image_timestamp, "%s").strftime("%A, %d %b %Y %l:%M %p"),
        report.recipients,
        report.subject,
        report.id
      ]
    end
    if !records.blank?
      render json: records
    end
  end
end