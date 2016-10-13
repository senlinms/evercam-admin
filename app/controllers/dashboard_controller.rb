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
    @cameras = Camera.includes(:user)
                     .where.not(users: {id: nil})
                     .where.not(location: nil).decorate
  end

  def maps_gardashared
    ids = []
    gardashared = CameraShare.where(user_id: 7011)
    gardashared.each do |share|
      ids[ids.count] = share.camera.id
    end
    @cameras = Camera.where(id: ids).where("location is not null").decorate
  end

  def maps_construction
    @cameras_owned = Camera.where(owner_id: 13959).where("location is not null").decorate
    ids = []
    construction_shared = CameraShare.where(user_id: 13959)
    construction_shared.each do |share|
      ids[ids.count] = share.camera.id
    end
    @cameras_shared = Camera.where(id: ids).where("location is not null").decorate
    @cameras = @cameras_owned + @cameras_shared
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
