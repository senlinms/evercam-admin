class UserDecorator < Draper::Decorator
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
           :payment_method,
           :insight_id

  def is_admin
    h.human_boolean(object.is_admin?)
  end

  def registered_at
    object.created_at.strftime("%d/%m/%y")
  end

  def confirmed_email
    h.human_boolean(object.confirmed_at.present?)
  end

  def country_name
    user.country.try(:name)
  end
end
