class SnapmailsController < ApplicationController

  def history   
  end

  def get_email_temaplate
    return SnapmailsHistory.find(params[:id]).body
  end

  def get_history_data
    if params[:date]
      date = params[:date]
    end
    @reports = SnapmailsHistory.where("DATE(inserted_at) = ?", date).order('inserted_at desc')
    records = []
    @reports.each do |report|
      records[records.length] = [
        report.inserted_at.strftime("%A, %d %b %Y %l:%M %p"),
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