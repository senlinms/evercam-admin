class UserDecorator < Draper::Decorator
  delegate :is_admin?, :username, :firstname, :lastname, :fullname, :email, :cameras, :country

  def admin
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
