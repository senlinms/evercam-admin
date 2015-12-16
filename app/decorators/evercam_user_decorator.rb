class EvercamUserDecorator < Draper::Decorator
  delegate :username,
           :firstname,
           :lastname,
           :fullname,
           :email,
           :is_admin?,
           :cameras,
           :country,
           :created_at,
           :camera_shares,
           :api_id,
           :api_key

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
end
