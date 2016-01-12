class DashboardController < ApplicationController
  before_action :authorize_admin

  def index
    @users = EvercamUser.all
    @cameras = Camera.all
    @new_users = @users.where('created_at >= ?', 1.month.ago).decorate
    @new_cameras = @cameras.where('created_at >= ?', 1.month.ago).decorate
  end

  def map
    @cameras = Camera.where.not(location: nil)
  end

  def kpi
    if params[:kpi_result]
      date = []
      11.downto(0) do |i|
        date.push(i.months.ago.strftime("%B %Y"))
      end
      new_cameras = []
      11.downto(0) do |i|
        new_cameras.push(Camera.created_months_ago(i).count)
      end
      total_cameras = []
      11.downto(0) do |i|
        if Camera.count > 0
          total_cameras.push(Camera.where(created_at: Camera.select(:created_at).order(:created_at).
                                              first.created_at..i.months.ago.end_of_month).count)
        end
      end
      new_paid_cameras = []
      11.downto(0) do |i|
        new_paid_cameras.push(Camera.new_paid_cameras(i).count)
      end
      total_paid_cameras = []
      11.downto(0) do |i|
        total_paid_cameras.push(Camera.total_paid_cameras(i).count)
      end
      new_users = []
      11.downto(0) do |i|
        new_users.push(EvercamUser.created_months_ago(i).count)
      end
      total_users = []
      11.downto(0) do |i|
        total_users.push(EvercamUser.where(created_at: EvercamUser.select(:created_at).order(:created_at).first.created_at..i.months.ago.end_of_month).count)
      end
      render json: [date: date, new_cameras: new_cameras, total_cameras: total_cameras,
                    new_paid_cameras: new_paid_cameras, total_paid_cameras: total_paid_cameras,
                    new_users: new_users, total_users: total_users
                   ]
    end
  end
end
