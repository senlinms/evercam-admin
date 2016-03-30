class DashboardController < ApplicationController
  before_action :authorize_admin

  def index
    @users = EvercamUser.all
    @cameras = Camera.all
    @new_users = @users.where('created_at >= ?', 1.month.ago).decorate
    @new_cameras = @cameras.where('created_at >= ?', 1.month.ago).decorate
    @countries = Country.all.to_ary
  end

  def map
    @cameras = Camera.where.not(location: nil).decorate
  end

  def maps_gardashared
    @public_cams = Camera.where.not(location: nil).where(is_public: true)
    pry
    public_count = @public_cams.count + 1
    gardashared = CameraShare.where(user_id: 7011)
    gardashared.each do |garda|
      @public_cams[public_count] = garda.camera
      public_count += 1
    end
    @public_cams
    pry
  end

  def kpi
    if params[:kpi_result]
      date = []
      new_cameras = []
      total_cameras = []
      new_paid_cameras = []
      total_paid_cameras = []
      total_users = []
      new_users = []
      11.downto(0) do |i|
        date.push(i.months.ago.strftime("%B %Y"))
        new_cameras.push(Camera.created_months_ago(i).count)
        if Camera.count > 0
          total_cameras.push(Camera.where(created_at: Camera.select(:created_at).order(:created_at).
                                              first.created_at..i.months.ago.end_of_month).count)
        else
          total_cameras.push(0)
        end
        new_paid_cameras.push(Camera.new_paid_cameras(i).count)
        total_paid_cameras.push(Camera.total_paid_cameras(i).count)
        new_users.push(EvercamUser.created_months_ago(i).count)
        total_users.push(EvercamUser.where(created_at: EvercamUser.select(:created_at).order(:created_at).first.created_at..i.months.ago.end_of_month).count)
      end
      render json: [date: date, new_cameras: new_cameras, total_cameras: total_cameras,
                    new_paid_cameras: new_paid_cameras, total_paid_cameras: total_paid_cameras,
                    new_users: new_users, total_users: total_users
                   ]
    end
  end
end
