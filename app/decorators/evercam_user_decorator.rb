class EvercamUserDecorator < Draper::Decorator
  delegate :username,
           :firstname,
           :lastname,
           :fullname,
           :email,
           :is_admin?,
           :cameras,
           :country_id,
           :country,
           :created_at,
           :camera_shares,
           :api_id,
           :api_key,
           :last_login_at,
           :id

  def is_admin
    h.human_boolean(object.is_admin?)
  end

  def registered_at
    object.created_at.strftime("%d/%m/%y %I:%M %p")
  end

  def confirmed_email
    h.human_boolean(object.confirmed_at.present?)
  end

  def country_name
    evercam_user.country.try(:name)
  end

  def last_login
    object.last_login_at.strftime("%d/%m/%y %I:%M %p") if object.last_login_at.present?
  end

  def licence_count
    count = 0
    object.licences.each do |licence|
      if licence.cancel_licence && Time.at(licence.end_date) > Time.now
        count += 1
      end
    end
    count
  end

  def cameras_with_cr
    count = 0
    object.cameras.each do |cam|
      if cam.cloud_recording.present? && !cam.cloud_recording.status.eql?("off")
        count += 1
      end
    end
    count
  end
end
